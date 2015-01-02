require 'metrics_influx/version'
require 'metrics_influx/module'
require 'metrics_influx'
require 'net/http'
require 'json'

class MetricsInflux::Engine
  class Error < StandardError; end

  def initialize(options, config)
    @config = config
    @collectors = config['collectors']
    @timers = Timers::Group.new

    @collectors.each do |coll|
      coll[:instance] = MetricsInflux::Module[coll['type']].new(coll['config'])
    end
  end

  def connection
    @http ||= begin
      raise ArgumentError, "Unknown InfluxDB protocol #{@config['server']['protocol']}" unless ['http', 'https'].include? @config['server']['protocol']
      http = Net::HTTP.new(@config['server']['host'], @config['server']['port'])
      http.use_ssl = @config['server']['protocol'] == 'https'
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if @config['server'].fetch('no_verify', false)
      http
    end
  end

  def do_query(q)
    request = Net::HTTP::Get.new("/db/#{@config['database']}/series?q=#{CGI.escape(q)}")
    request.basic_auth @config['server']['user'], @config['server']['pass']
    connection.request(request)
  end

  def test_connection!
    response = do_query('list series')
    raise Error.new response.body unless response.kind_of? Net::HTTPSuccess
    MetricsInflux.logger.debug "influxdb: Connection tested successfully"
  end

  def do_post!(data)
    request = Net::HTTP::Post.new("/db/#{@config['database']}/series?time_precision=s")
    request.basic_auth @config['server']['user'], @config['server']['pass']
    request.add_field('Content-Type', 'application/json')
    request.body = data.to_json
    response = connection.request(request)
    raise Error.new response.body unless response.kind_of? Net::HTTPSuccess
  end

  def run!
    grouped_collectors = @collectors.group_by { |coll| coll['interval'] }

    grouped_collectors.each do |interval,collectors|
      @timers.every(interval) { sample(collectors) }
    end

    loop { @timers.wait }
  end

  def sample(collectors)
    futures = collectors.map { |coll| { coll: coll, future: coll[:instance].future(:sample) } }

    data = []

    futures.each do |c|
      coll = c[:coll]
      kvs = c[:future].value
      kvs = [kvs] if kvs.is_a? Hash
      kvs.each do |kv|
        data << {
          name:           coll['series'],
          columns:        kv.keys.map { |k| "#{coll['prefix'] || ""}#{k}" },
          points:         [ kv.values ]
        }
      end
    end

    begin
      do_post! data
    rescue MetricsInflux::Engine::Error => e
      DockerBoss.logger.error "Error posting update: #{e.message}"
    rescue Net::OpenTimeout => e
      DockerBoss.logger.error "Error posting update: #{e.message}"
    rescue Errno::ECONNREFUSED => e
      DockerBoss.logger.error "Error posting update: #{e.message}"
    rescue SocketError => e
      DockerBoss.logger.error "Error posting update: #{e.message}"
    end
  end
end

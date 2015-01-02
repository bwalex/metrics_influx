require 'metrics_influx/module'
require 'metrics_influx'

class MetricsInflux::Module::SysNetStat < MetricsInflux::Module::Base
  class Error < StandardError; end

  def initialize(config, params = {})
    @config = config
    @config['stats'] ||= %w(rx_packets rx_bytes rx_errors tx_packets tx_bytes tx_errors)
    @config['interfaces'] ||= Dir.glob('/sys/class/net/*').map { |f| File.basename f }
    @params = params
  end

  def sample
    @config['interfaces'].map do |intf|
      data = { time: Time.now.to_i }
      @config['stats'].each do |k|
        v = File.read("/sys/class/net/#{intf}/statistics/#{k}").chomp
        data["#{intf}_#{k}"] = v.to_i
      end
      data
    end
  end
end

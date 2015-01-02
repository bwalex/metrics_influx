require 'metrics_influx/version'
require 'metrics_influx/engine'
require 'metrics_influx'

require 'thor'
require 'logger'
require 'syslog/logger'
require 'daemons'
require 'yaml'

class MetricsInflux::CLI < Thor

  desc "collect", ""
  method_option :config,    :aliases => "-c", :type => :string,  :required => true
  method_option :log,       :aliases => "-l", :type => :string,  :default => "-", :desc => "Specify a file to log to, or '-' to log to the standard output, or 'syslog' to log to syslog"
  method_option :debug,     :aliases => "-d", :type => :boolean, :default => false, :desc => "Specify this option to run with debug logging enabled"
  method_option :daemonize, :aliases => "-D", :type => :boolean, :default => false, :desc => "Specify this option to daemonize the process instead of running in the foreground"
  def collect
    setup_logging
    read_config
    Daemons.daemonize if options[:daemonize]
    begin
      engine.run!
    rescue SignalException => e
      case Signal.signame(e.signo)
      when "TERM", "INT"
        MetricsInflux.logger.info "Received SIGTERM/SIGINT, shutting down."
        exit 0
      else
        MetricsInflux.logger.fatal "Fatal unhandled signal in event loop: #{Signal.signame(e.signo)}"
        e.backtrace.each { |line| MetricsInflux.logger.fatal " #{line}" }
      end
    rescue Exception => e
      MetricsInflux.logger.fatal "Fatal unhandled exception in event loop: #{e.class.name} -> #{e.message}"
      e.backtrace.each { |line| MetricsInflux.logger.fatal " #{line}" }
      exit 1
    end
  end

  no_tasks do
    def engine
      @engine ||= begin
        engine = MetricsInflux::Engine.new(options, @config)
        engine
      end
    end

    def setup_logging
      case options[:log]
      when "syslog"
        @logger = Syslog::Logger.new('metrics-influx')
      when "-"
        @logger = Logger.new(STDOUT)
      else
        @logger = Logger.new(options[:log])
      end
      @logger.level = options[:debug] ? Logger::DEBUG : Logger::INFO
      MetricsInflux.logger=(@logger)
    end

    def read_config
      begin
        @config = YAML.load_file(options[:config])
      rescue SyntaxError => e
        MetricsInflux.logger.fatal "Error loading config: #{e.message}"
        exit 1
      end
    end
  end
end

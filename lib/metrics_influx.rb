require 'metrics_influx/version'
require 'celluloid'

module MetricsInflux
  def self.logger
    @@logger ||= Logger.new(STDOUT)
  end

  def self.logger=(logger)
    @@logger = logger
    Celluloid.logger = logger
  end
end

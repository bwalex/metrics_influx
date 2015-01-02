require 'metrics_influx/module'
require 'metrics_influx'

class MetricsInflux::Module::GraphiteCLI < MetricsInflux::Module::Base
  class Error < StandardError; end

  def initialize(config, params = {})
    @config = config
    @params = params
  end

  def sample
    time_now = Time.now.to_i
    data = { time: time_now }
    output = %x(#{@config['cmd']})
    output.lines.each do |line|
      (k,v,time) = line.split(/\s+/, 3)
      data[k] = v
      data[:time] = time if time
    end
    data
  end
end

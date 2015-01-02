require 'metrics_influx/module'
require 'metrics_influx'

class MetricsInflux::Module::ProcVmstat < MetricsInflux::Module::Base
  class Error < StandardError; end

  def initialize(config, params = {})
    @config = config
    @params = params
  end

  def sample
    time_now = Time.now.to_i
    data = { time: time_now }
    File.readlines('/proc/vmstat').each do |line|
      (k,v) = line.chomp.split(/\s+/, 2)
      data[k.downcase] = v.to_i
    end
    data
  end
end

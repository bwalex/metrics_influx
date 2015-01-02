require 'metrics_influx/module'
require 'metrics_influx'

class MetricsInflux::Module::ProcMeminfo < MetricsInflux::Module::Base
  class Error < StandardError; end

  def initialize(config, params = {})
    @config = config
    @params = params
  end

  def sample
    time_now = Time.now.to_i
    data = { time: time_now }
    File.readlines('/proc/meminfo').each do |line|
      (k,v,unit) = line.chomp.split(/\s+/, 3)
      key = k[0..-2].gsub(/\(([^\)]+)\)/, '_\1')
      v = v.to_i
      case unit
      when 'kB'
        v *= 1024
      when 'MB'
        v *= 1024 * 1024
      when 'GB'
        v *= 1024 * 1024 * 1024
      when 'TB'
        v *= 1024 * 1024 * 1024 * 1024
      end
      data[k.downcase] = v
    end
    data
  end
end

require 'metrics_influx/module'
require 'metrics_influx'

class MetricsInflux::Module::ProcStatProcs < MetricsInflux::Module::Base
  class Error < StandardError; end

  def initialize(config, params = {})
    @config = config
    @params = params
  end

  def sample
    time_now = Time.now.to_i
    data = { time: time_now }
    File.readlines('/proc/stat').each do |line|
      (k,v) = line.chomp.split(/\s+/, 2)
      data[k.downcase] = v.to_i if %w(ctxt processes procs_running procs_blocked).include? k
    end
    data
  end
end

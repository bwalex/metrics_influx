require 'metrics_influx/module'
require 'metrics_influx'

class MetricsInflux::Module::ProcLoadavg < MetricsInflux::Module::Base
  class Error < StandardError; end

  def initialize(config, params = {})
    @config = config
    @params = params
  end

  def sample
    time_now = Time.now.to_i
    line = File.readlines('/proc/loadavg').first
    (avg_1min, avg_5min, avg_15min, procs, last_pid) = line.chomp.split(/\s+/, 5)
    (thread_run, thread_total) = procs.split(/\//, 2)

    {
      time:           time_now,
      load_avg1min:   avg_1min.to_f,
      load_avg5min:   avg_5min.to_f,
      load_avg15min:  avg_15min.to_f,
      entities_run:   thread_run.to_i,
      entities_total: thread_total.to_i
    }
  end
end

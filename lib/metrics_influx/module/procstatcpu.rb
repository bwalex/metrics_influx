require 'metrics_influx/module'
require 'metrics_influx'

class MetricsInflux::Module::ProcStatCpu < MetricsInflux::Module::Base
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
      if k == "cpu"
        vals = v.split(/\s+/)
        %w(user nice sys idle iowait irq softirq steal guest guest_nice).each_with_index do |key,idx|
          data[key] = vals.fetch(idx, 0).to_i
        end
      end
    end
    data
  end
end

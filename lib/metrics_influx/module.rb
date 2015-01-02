require 'metrics_influx/version'
require 'metrics_influx'

require 'celluloid'

module MetricsInflux::Module
  @modules = {}

  def self.<<(klass)
    key = klass.name.split('::')[-1].downcase
    @modules[key] = klass
  end

  def self.[](key)
    key = key.downcase

    unless @modules.has_key? key
      path = "metrics_influx/module/#{key}"

      spec = Gem::Specification.find_by_path(path)
      unless spec.nil?
        activated = spec.activate
        MetricsInflux.logger.info "Activated gem `#{spec.full_name}`" if activated
      end

      begin
        require path
      rescue LoadError
      end
    end

    raise IndexError, "Unknown module #{key}" unless @modules.has_key? key
    @modules[key]
  end

  class Base
    def self.inherited(klass)
      klass.include Celluloid
      MetricsInflux::Module << klass
    end
  end
end

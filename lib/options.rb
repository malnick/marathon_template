module Marathon_template
  class Options
    def self.initialize(config_path)

      # Env variable prefix
      prefix = 'MARATHON_TEMPLATE_'

      # Temp and instance vars for config
      config_file = Hash.new
      @config     = Hash.new

      unless File.exists? config_path
        abort LOG.error "Config file not found! Please make sure #{config_path} exists."
      end

      LOG.info "##### Configuration #####"
      LOG.info '*'
      file = YAML.load(File.open(config_path, 'r'))
      file.each do |k,v|
        config_file[k] = v
      end

      # Configuration
      @config[:haproxy_global]      = ENV["#{prefix}haproxy_global"]    || config_file['haproxy']['global']
      @config[:haproxy_defaults]    = ENV["#{prefix}haproxy_defaults"]  || config_file['haproxy']['defaults']

      @config.each do |k,v|
        LOG.info("#{k}: #{v}")
      end
      @config
    end
  end
end

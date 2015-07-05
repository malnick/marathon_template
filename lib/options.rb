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
      @config[:marathon]            = config_file['marathon']               || 'localhost:8080'
      @config[:haproxy_global]      = config_file['haproxy']['global']      #|| abort "Must pass global options in haproxy.yaml" 
      @config[:haproxy_defaults]    = config_file['haproxy']['defaults']    #|| abort "Must pass default options in haproxy.yaml"
      @config[:haproxy_listen]      = config_file['haproxy']['listens']     || nil
      @config[:haproxy_frontends]   = config_file['haproxy']['frontends']   || nil
      @config[:haproxy_backends]    = config_file['haproxy']['backends']    || nil
      
      # Determine where HaProxy lives
#      distro = IO.popen('uname').readlines
#      if distro == 'Linux' 
#        @config[:distro] = distro
#      else
#        abort "Sorry, #{distro} is not supported." 
#      end

      @config.each do |k,v|
        LOG.info("#{k}: #{v}")
      end
      @config
    end
  end
end

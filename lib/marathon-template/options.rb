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
      @config[:haproxy_path]        = config_file['haproxy_path']           || '/etc/haproxy'
      @config[:cron_splay]          = config_file['cron_splay_time']        || '* * * * * root /usr/local/bin/marathon-template > /var/log/marathon-template-lastrun.log 2>&1'
      @config.each do |k,v|
        LOG.info("#{k}: #{v}")
      end       
    end
  end
end

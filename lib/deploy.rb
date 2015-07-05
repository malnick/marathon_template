module Marathon_template
  class Deploy
    def self.haproxy(config)
      write_haproxy_cfg(config)
      reload_haproxy_service
    end

    def write_haproxy_cfg
      File.open('/etc/haproxy/haproxy.test') do |f|
        if @config[:haproxy_global] 
          f.write 'global'
          @config[:haproxy_global].each do |k,v|
            LOG.info k + v
            f.write k + v
          end
        else
          abort "Must pass global parameters in haproxy.yaml"
        end
      end
    end

    def reload_haproxy_service
      system("service haproxy reload")
    end

  end
end

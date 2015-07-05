module Marathon_template
  class Deploy
    def self.haproxy
      write_haproxy_cfg
      #reload_haproxy_service
    end

    def self.write_haproxy_cfg
      File.open('/Users/malnick/projects/mesosphere_template/ext/haproxy.test', 'wb') do |f|
        if CONFIG[:haproxy_global] 
          f.write "global\n"
          CONFIG[:haproxy_global].each do |directive,value|
            if value.kind_of?(Array)
              value.each do |value|
                f.write "\t#{directive} #{value}\n"
              end
            else
              f.write "\t#{directive}\n"
            end
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

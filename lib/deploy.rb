module Marathon_template
  class Deploy
    def self.haproxy
      write_haproxy_cfg
      #reload_haproxy_service
    end

    def self.write_haproxy_cfg
      File.open('/Users/malnick/projects/mesosphere_template/ext/haproxy.test', 'wb') do |f|
        # Write out the global section
        if CONFIG[:haproxy_global] 
          f.write "global\n"
          CONFIG[:haproxy_global].each do |directive,values|
            if values.kind_of?(Array)
              values.each do |value|
                f.write "\t#{directive} #{value}\n"
              end
            elsif values.kind_of?(Hash)
              values.each do |k,v|
                f.write "\t#{k} #{v}\n"
              end
            else
              f.write "\t#{directive} #{values}\n"
            end
          end
        else
          abort "Must pass global parameters in haproxy.yaml"
        end
        
        # Write out the defaults section
        if CONFIG[:haproxy_defaults] 
          f.write "defaults\n"
          CONFIG[:haproxy_defaults].each do |directive,values|
            if values.kind_of?(Array)
              values.each do |value|
                f.write "\t#{directive} #{value}\n"
              end
            elsif values.kind_of?(Hash)
              values.each do |k,v|
                f.write "\t#{k} #{v}\n"
              end
            else
              f.write "\t#{directive} #{values}\n"
            end
          end
        else
          abort "Must pass default parameters in haproxy.yaml"
        end

        # Write out the listners section
        if CONFIG[:haproxy_listen] 
          CONFIG[:haproxy_listen].each do |listener, configuration|
          f.write "listen #{listener}\n"
            configuration.each do |setting, values|
              if values.kind_of?(Array)
                values.each do |value|
                  f.write "\t#{setting} #{value}\n"
                end
              elsif values.kind_of?(Hash)
                values.each do |k,v|
                  f.write "\t#{k} #{v}\n"
                end
              else
                f.write "\t#{setting} #{values}\n"
              end
            end
          end
        end

      end
    end

    def reload_haproxy_service
      system("service haproxy reload")
    end

  end
end

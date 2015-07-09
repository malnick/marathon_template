module Marathon_template
  class Deploy
    def self.haproxy
      test_haproxy_dir
      write_haproxy_cfg
      reload_haproxy_service
    end

    def self.write_haproxy_cfg
      File.open("#{CONFIG[:haproxy_path]}/haproxy.cfg", 'wb') do |f|
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
                f.write "\t#{directive} #{k} #{v}\n"
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
                f.write "\t#{directive} #{k} #{v}\n"
              end
            else
              f.write "\t#{directive} #{values}\n"
            end
          end
        else
          abort "Must pass default parameters in haproxy.yaml"
        end

        # Write out the listners sections
        if CONFIG[:haproxy_listen] 
          CONFIG[:haproxy_listen].each do |listener, configuration|
          f.write "listen #{listener}\n"
            configuration.each do |setting, values|
              if setting == 'server'
                app_name  = values['app_name']
                options   = values['options']
                servers   = get_servers(app_name)
                LOG.info "#{app_name}: #{servers}"
                servers.each do |host, port|
                  f.write "\tserver #{app_name}-#{host.split('_').last} #{host.split('_').first}:#{port.first} #{options}\n"
                end 
              elsif values.kind_of?(Array)
                values.each do |value|
                  f.write "\t#{setting} #{value}\n"
                end
              elsif values.kind_of?(Hash)
                values.each do |k,v|
                  f.write "\t#{setting} #{k} #{v}\n"
                end
              else
                f.write "\t#{setting} #{values}\n"
              end
            end
          end
          # TODO include calling class to build servers 
        end

        # Write out the frontends sections
        if CONFIG[:haproxy_frontends] 
          CONFIG[:haproxy_frontends].each do |frontend, configuration|
          f.write "frontend #{frontend}\n"
            configuration.each do |setting, values|
              if values.kind_of?(Array)
                values.each do |value|
                  f.write "\t#{setting} #{value}\n"
                end
              elsif values.kind_of?(Hash)
                values.each do |k,v|
                  f.write "\t#{setting} #{k} #{v}\n"
                end
              else
                f.write "\t#{setting} #{values}\n"
              end
            end
          end
        end

        # Write out the backends sections
        if CONFIG[:haproxy_backends] 
          CONFIG[:haproxy_backends].each do |backend, configuration|
          f.write "backend #{backend}\n"
            configuration.each do |setting, values|
              if setting == 'server'
                app_name  = values['app_name']
                options   = values['options']
                servers   = get_servers(app_name)
                if values['management_port']
                  LOG.info "#{app_name}: #{servers}"
                  servers.each do |host, port|
                    f.write "\tserver #{app_name}-#{host.split('_').last} #{host.split('_').first}:#{port[0]} #{options} port #{port[1]}\n"
                  end
                else
                  servers.each do |host, port|
                    f.write "\tserver #{app_name}-#{host.split('_').last} #{host.split('_').first}:#{port[0]} #{options}\n"
                  end
                end
              elsif values.kind_of?(Array)
                values.each do |value|
                  f.write "\t#{setting} #{value}\n"
                end
              elsif values.kind_of?(Hash)
                values.each do |k,v|
                  f.write "\t#{setting} #{k} #{v}\n"
                end
              else
                f.write "\t#{setting} #{values}\n"
              end
            end
          end
        end
      end
    end

    def self.get_servers(app_name)
      begin
        LOG.info "Getting host and port assignments for #{app_name}..."
        marathon_app      = "#{CONFIG[:marathon]}/v2/apps/#{app_name}"
        encoded_uri       = URI.encode(marathon_app.to_s)
        uri               = URI.parse(encoded_uri)
        http              = Net::HTTP.new(uri.host, uri.port)
        request           = Net::HTTP::Get.new(uri.request_uri)
        response          = http.request(request)

        if response.code == '200'
          return_hash = Hash.new 
          json        = JSON.parse(response.body)
          tasks       = json['app']['tasks']
          tasks.each_with_index do |task, i|
            LOG.info "Found host #{task['host']} and port #{task['ports']}"
            return_hash["#{task['host']}_#{i}"] = task['ports']
  #          if task['ports'].length == 1
  #+             LOG.info "Found host #{task['host']} and port #{task['ports']}"
  #              return_hash[i] = { task['host'] => task['port'] }
  #              return_array << "#{task['host']}:#{task['ports'][1]}"
          end
        else
          if response.code == '404'
            abort LOG.error "Failed connecting to #{marathon_app}, response code: #{response.code}\n Are you sure the app #{app_name} exists?"
          else
            abort LOG.error "Failed connecting to #{marathon_app}, response code: #{response.code}"
          end
        end
        return_hash
      rescue Exception => e
        e.message
        e.backtrace
      end
    end

    def self.test_haproxy_dir
      unless Dir.exists? CONFIG[:haproxy_path]
        LOG.info "#{CONFIG[:haproxy_path]} not found, creating..."
        Dir.mkdir CONFIG[:haproxy_path]
      end
    end

    def self.reload_haproxy_service
      system("service haproxy reload")
    end

  end
end

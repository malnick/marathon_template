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
                if servers['404'] #== '404' 
        LOG.info servers
                  LOG.info "#{app_name} was not found in Marathon, skipping but continuing to manage the haproxy.cfg"
                elsif values['management_port']
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
      LOG.info "Getting host and port assignments for #{app_name}..."
      # Setup the URI for marathon and check it before moving on
      marathon_app      = "#{CONFIG[:marathon]}/v2/apps/#{app_name}"
      unless URI.parse(URI.encode(marathon_app)) 
        abort LOG.info "The URI for #{marathon_app} doesn't look right." 
      end
      LOG.info "Querying #{marathon_app}"
      # Parse the URI for reals and make a request
      encoded_uri       = URI.encode(marathon_app.to_s)
      uri               = URI.parse(encoded_uri)
      http              = Net::HTTP.new(uri.host, uri.port)
      request           = Net::HTTP::Get.new(uri.request_uri)
      response          = http.request(request)
      return_hash       = Hash.new 
      # If we get a 200, lets return the servier hosts and ports assignments
      if response.code == '200'
        json        = JSON.parse(response.body)
        tasks       = json['app']['tasks']
        tasks.each_with_index do |task, i|
          LOG.info "Found host #{task['host']} and port #{task['ports']}"
          return_hash["#{task['host']}_#{i}"] = task['ports']
        end
      # If we don't then do not blow up, simply return not found and move on. This way usable servers still get proxied. 
      elsif response.code == '404'
        LOG.warn "Response code: #{response.code}"
        LOG.warn "Are you sure the app #{app_name} exsts?"
        return_hash[response.code] = 'not_found' 
        LOG.info return_hash
      else
        abort LOG.error "Got #{response.code} which is neither 404 or 200"
      end
      return_hash
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

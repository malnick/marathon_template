module Marathon_template
  class Cron
    def self.add
      if CONFIG[:cron_splay]
        LOG.info "Setting up cron job..."
        if File.exists? '/etc/crontab'
          if File.open('/etc/crontab').each_line.any? { |line| line.chomp == "#{CONFIG[:cron_splay]}" }
            LOG.info "Cron already configured."
            return 
          else
            File.open('/etc/crontab', 'a') do |w|
              LOG.info "Appending #{CONFIG[:cron_splay]} to /etc/crontab"
              w.write CONFIG[:cron_splay]
            end
          end
        else
          LOG.info "No crontab found, creating and adding #{CONFIG[:cron_splay]}"
          File.open('/etc/crontab', 'wb') do |w|
            w.write CONFIG[:cron_splay]
          end
        end
      end
    end
  end
end

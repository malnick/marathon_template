module Marathon_template
  class Cron
    def self.add
      unless CONFIG[:cron_splay]
        abort "Please set 'cron_splay_time' in haproxy.yaml"
      end
      if File.exists? '/etc/crontab'
        return if File.readlines('/etc/crontab').grep(CONFIG[:cron_splay]).any?
      else
        File.open('/etc/crontab', 'a') do |w|
          w.write CONFIG[:cron_splay]
        end
      else
        File.open('/etc/crontab', 'wb') do |w|
          w.write CONFIG[:cron_splay]
        end
      end
    end
  end
end

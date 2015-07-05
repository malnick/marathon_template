# Marathon Template
Generate dynamic haproxy config. 

## Method

Eventually: ```gem install marathon_template```

1. Declare haproxy baseline config (frontends, backends, etc) in /etc/haproxy.yaml
2. ```marathon_template deploy``` 
  1. Installs HaProxy 1.5x
  2. Configures cron job to update haproxy.cfg every minute


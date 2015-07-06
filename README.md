# Marathon Template
Generate dynamic haproxy config. 

## Modifies

1. /etc/haproxy/haproxy.cfg - marathon template will purge existing haproxy.cfg file
1. /etc/crontab - marathon template will append a cron job to execute marathon template every minute, splay time can be set in /etc/haproxy.yaml

## Setup

1. ```cp ext/haproxy_example.yaml /etc/haproxy.yaml```
1. ``` sudo ruby bin/marathon_template.rb```

## Method

Eventually: ```gem install marathon_template```

1. Declare haproxy baseline config (frontends, backends, etc) in /etc/haproxy.yaml

Example, declare your global and default options - parameters specified multiple times can be declared once and passed an array of values:

```yaml
---
marathon: 'http://10.33.100.11:8080'
haproxy:
  global:
    daemon:
    log:
      - '127.0.0.1 local0'
      - '127.0.0.1 local1 notice'
    maxconn: 4096
  defaults:
    log: global
    mode: http
    retries: 3
    maxconn: 2000
    timeout:
      connect: '5s'
      client: '50s'
      server: '50s'
      http-keep-alive: 1s
      http-request: 15s
      queue: 30s
      tarpit: 60s
    option:
      - httplog
      - dontlognull
      - forwardfor
      - http-server-close
      - redispatch
```

This yields:

```bash
global
  daemon
  log 127.0.0.1 local0
  log 127.0.0.1 local1 notice
  maxconn 4096
defaults
  log global
  mode http
  retries 3
  maxconn 2000
  connect 5s
  client 50s
  server 50s
  http-keep-alive 1s
  http-request 15s
  queue 30s
  tarpit 60s
  option httplog
  option dontlognull
  option forwardfor
  option http-server-close
  option redispatch
```

## Dynamic application host and port assignment
In order to dynamically configure a specific app in a specific listen or backend server block, add the following 'server' definition to the listen or backend of choice in haproxy.yaml:

```yaml
listens:
  stats_test:
    bind: '0.0.0.0:9090'
    mode: http
    stats:
      - enable
      - hide-version
      - 'url /'
      - 'auth admin:admin'
  my_app:
    bind: '0.0.0.0:80'
    mode: http
    balance: roundrobin
    server:
~     app_name: my_app
      options: check
```

or in your backend section of choice:

```yaml
backends:
  my_app:
    balance: leastconn
    option: forwardfor
    http-request:
      - 'http-request set-header X-Forwarded-Port %[dst_port]'
    server:
      app_name: my_app
      options: check
```

These configurations will query the spcificed marathon in haproxy.yaml for ```GET /v2/apps/${app_name}``` and yield the following server lines to the listen or backend blocks respectively:

Listen: 

```
listen my_app 
  bind 0.0.0.0:80
  mode http
  balance roundrobin
  my_app mesosslave1:31000 check
  my_app mesosslave2:31000 check
```

Backend:

```
backend my_app 
  balance leastconn
  option forwardfor
  http-request http-request set-header X-Forwarded-Port %[dst_port]
  my_app mesosslave1:31000 check
  my_app mesosslave2:31000 check
```

## Execute
```bin/marathon_template start``` 

1. Reads ```/etc/haproxy_example.yaml``` and queries the specified marathon for any server['app_name'] definitions in 'backend' or 'listen' sections; writes the haproxy configuration to the filesystem, currently ```/etc/haproxy/haproxy.cfg```


## TODO

1. Marathon_template::Install - install haproxy veresion specified in haproxy.yaml

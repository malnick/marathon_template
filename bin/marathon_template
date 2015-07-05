#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

case "$1" in
  start)
    ruby $DIR/marathon_template.rb
    echo $? > /var/run/marathon_template.pid
    ;;
  stop)
    kill -9 $(cat /var/run/marathon_template.pid) 
    ;;
  restart|reload)
    $0 stop
    $0 start
    ;;
  *)
    echo "Usage: start|stop|restart|reload"
    exit 1
    ;;
esac
exit 0

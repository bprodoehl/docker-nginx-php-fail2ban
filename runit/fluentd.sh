#!/bin/sh

exec /usr/local/bin/fluentd --use-v1-config -c /etc/fluent/fluent.conf -vv >>/var/log/fluentd.log 2>&1

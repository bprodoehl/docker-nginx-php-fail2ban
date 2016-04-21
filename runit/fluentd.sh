#!/bin/bash

if [[ -n "$KINESIS_STREAM" && -n "$AWS_ACCESS_KEY_ID" && -n "$AWS_SECRET_ACCESS_KEY" && -n "$KINESIS_REGION" ]]; then
  exec /usr/local/bin/fluentd --use-v1-config -c /etc/fluent/fluent.conf -vv >>/var/log/fluentd.log 2>&1
else
  echo Not running fluentd.
fi

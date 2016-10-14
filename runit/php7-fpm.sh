#!/bin/sh

mkdir -p /run/php
exec /usr/sbin/php-fpm7.0 -c /etc/php7/fpm/ --nodaemonize

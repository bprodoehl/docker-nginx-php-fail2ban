FROM phusion/baseimage:0.9.15

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

ONBUILD ADD html /usr/share/nginx/html/

EXPOSE 80 443

RUN apt-get update && apt-get dist-upgrade -y

RUN echo "deb http://ppa.launchpad.net/nginx/development/ubuntu $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/nginx-stable.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C
RUN apt-get update -q
RUN apt-get install -y nginx nginx-extras

RUN apt-get install -qy php5-fpm php5-mysql php5-curl wget unzip fail2ban \
                        sendmail iptables-persistent

# disable SSH, because we don't need it
RUN touch /etc/service/sshd/down

RUN mkdir /etc/service/nginx
ADD runit/nginx.sh /etc/service/nginx/run

RUN mkdir /etc/service/php5-fpm
ADD runit/php5-fpm.sh /etc/service/php5-fpm/run

ADD config/nginx.conf /etc/nginx/nginx.conf
ADD config/nginx-default.conf /etc/nginx/sites-available/default
ADD config/nginx-cf-realip.conf /etc/nginx/conf.d/
ADD config/php.ini /etc/php5/fpm/php.ini

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

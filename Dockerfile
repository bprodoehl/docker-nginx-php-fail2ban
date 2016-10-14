FROM phusion/baseimage:0.9.19

ENV HOME /root

CMD ["/sbin/my_init"]

#ONBUILD ADD ./html /usr/share/nginx/html/

EXPOSE 80 443

RUN apt-get update && apt-get dist-upgrade -y

RUN echo "deb http://ppa.launchpad.net/nginx/development/ubuntu $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/nginx-stable.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C
RUN apt-get update -q
RUN apt-get install -y nginx nginx-extras

RUN DEBIAN_FRONTEND=noninteractive apt-get install -qy php7.0-fpm \
    php7.0-mysql php7.0-curl wget unzip fail2ban sendmail iptables-persistent \
    curl build-essential ruby ruby-dev git logrotate

# disable SSH, because we don't need it
RUN touch /etc/service/sshd/down

# disable sendmail cron job, because we don't need it
RUN rm /etc/cron.d/sendmail

RUN mkdir /etc/service/nginx
COPY runit/nginx.sh /etc/service/nginx/run

RUN mkdir /etc/service/php7-fpm
COPY runit/php7-fpm.sh /etc/service/php7-fpm/run

COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx-default.conf /etc/nginx/sites-available/default
COPY config/nginx-cf-realip.conf /etc/nginx/conf.d/
COPY config/php.ini /etc/php7/fpm/php.ini

RUN gem install bundler --no-ri --no-rdoc

# install Kinesis fluentd plugin
WORKDIR /root
RUN git clone https://github.com/awslabs/aws-fluent-plugin-kinesis.git
WORKDIR /root/aws-fluent-plugin-kinesis
RUN bundle install
RUN rake build
RUN rake install

RUN mkdir /etc/fluent

COPY config/fluent.conf /etc/fluent/
COPY config/nginx-json.conf /etc/nginx/conf.d/

# Logrotate
COPY config/logrotate-nginx.conf /etc/logrotate.d/nginx
RUN chmod 0644 /etc/logrotate.d/nginx
RUN mv /etc/cron.daily/logrotate /etc/cron.hourly/

COPY runit/fluentd.sh /etc/service/fluentd/run

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

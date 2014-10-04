FROM phusion/baseimage:0.9.13

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

RUN echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/nginx-stable.list
RUN sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C
RUN sudo apt-get update -q
RUN sudo apt-get install -y nginx

RUN apt-get install -qy php5-fpm php5-mysql php5-curl wget unzip

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

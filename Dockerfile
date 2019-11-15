FROM ubuntu:latest
MAINTAINER Name<email>
ENV DEBIAN_FRONTEND noninteractive
# Install basics
RUN apt-get update
RUN apt-get install -y apt-utils apt-transport-https curl sudo locales gnupg 
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | tee /etc/apt/sources.list.d/mssql-tools.list
RUN apt-get update
RUN apt-get install -y language-pack-en-base dialog
RUN sudo locale-gen en_US.UTF-8
RUN apt-get install -y software-properties-common && LC_ALL=en_UK.UTF-8 add-apt-repository -y ppa:ondrej/php && apt-get update
RUN sudo ACCEPT_EULA=Y apt-get install -y mssql-tools
# Install PHP 7.1
RUN apt-get install -y --allow-unauthenticated php php-mysql php-cli php-gd php-curl php-dev php-xml mcrypt php-mbstring php-pear
RUN apt-get install -y php-zip
RUN apt-get install -y unixodbc-dev
RUN apt-get install -y openssh-server jed
RUN sudo echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /etc/bash.bashrc
RUN sudo pecl install sqlsrv
RUN sudo pecl install pdo_sqlsrv
RUN sudo echo 'extension=pdo_sqlsrv.so' >> /etc/php/7.3/apache2/php.ini
RUN sudo echo 'extension=sqlsrv.so' >> /etc/php/7.3/apache2/php.ini
# Enable apache mods.
RUN apt-get install php
RUN a2enmod php7.3
RUN a2enmod rewrite
# Update the PHP.ini file, enable <? ?> tags and quieten logging.
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/7.3/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php/7.3/apache2/php.ini
# Manually set up the apache environment variables
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
# Expose apache.
EXPOSE 80
EXPOSE 8080
EXPOSE 443
EXPOSE 3306
# Update the default apache site with the config we created.
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf
# By default start up apache in the foreground, override with /bin/bash for interative.
CMD /usr/sbin/apache2ctl -D FOREGROUND

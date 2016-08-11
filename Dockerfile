FROM ubuntu:14.04
MAINTAINER Housni Yakoob <housni.yakoob@gmail.com>

ENV TERM xterm

# disable interactive functions
ENV DEBIAN_FRONTEND noninteractive

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

EXPOSE 80
EXPOSE 443

# RUN usermod -u 1000 www-data

RUN apt-get update && \
    apt-get install -y \
    apache2 \
    curl \
    git \
    libapache2-mod-php5 \
    libssl-dev \
    mysql-client \
    php5 \
    php5-mcrypt \
    php5-mysql \
    unzip \
    vim \
    zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure php.ini
RUN sed -i -e "s/^display_errors.*/display_errors = On/g" /etc/php5/apache2/php.ini \
    && sed -i -e "s/^display_startup_error.*/display_startup_error = On/g" /etc/php5/apache2/php.ini \
    && sed -i -e "s/^log_errors.*/log_errors = On/g" /etc/php5/apache2/php.ini \
    && sed -i -e "s/^log_errors_max_len.*/log_errors_max_len = 1024/g" /etc/php5/apache2/php.ini \
    && sed -i -e "s/^error_reporting.*/error_reporting = E_ALL/g" /etc/php5/apache2/php.ini

# Enable mod_rewrite.
RUN /usr/sbin/a2enmod rewrite \
    && /usr/sbin/a2enmod ssl

COPY ./vhost.conf /etc/apache2/sites-enabled/000-default.conf

# Installing npm for Newman (aka Postman CLI).
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - && \
    apt-get install -y nodejs  && \
    npm install newman --global

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

WORKDIR /var/www/html/
# Removing the default index.html installed by Apache.
RUN rm index.html
COPY ./composer.json ./composer.lock ./
RUN composer install --no-interaction

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

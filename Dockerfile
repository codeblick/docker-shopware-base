FROM ubuntu:18.04

ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh /bin/wait-for-it.sh
RUN chmod +x /bin/wait-for-it.sh

ADD https://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C /
ENTRYPOINT ["/init"]
CMD []

ENV DEBIAN_FRONTEND noninteractive
ARG PHP_VERSION
ENV PHP_VERSION=$PHP_VERSION

ENV PHP_XDEBUG=0
ENV PHP_XDEBUG_HOST=docker.host
ENV PHP_XDEBUG_IDEKEY=VSCODE
ENV PHP_XDEBUG_PORT=9001

RUN apt update && apt install -y software-properties-common curl inetutils-syslogd && \
    apt-add-repository ppa:ondrej/apache2 -y && \
    LC_ALL=C.UTF-8 apt-add-repository ppa:ondrej/php -y && \
    apt update && apt install -y \
        php${PHP_VERSION}-fpm \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-zip \
        php${PHP_VERSION}-json \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-apcu \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-xdebug \
        # php${PHP_VERSION}-memcached \
        # php${PHP_VERSION}-redis \
    apache2 && \
    apt autoremove -y && apt clean && rm -rf /var/lib/apt/lists/* && \
    mkdir -p /run/php && chmod -R 755 /run/php && \
    sed -i 's|.*listen =.*|listen=9000|g' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
    sed -i 's|.*error_log =.*|error_log=/proc/self/fd/2|g' /etc/php/${PHP_VERSION}/fpm/php-fpm.conf && \
    sed -i 's|.*access.log =.*|access.log=/proc/self/fd/2|g' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
    sed -i 's|.*user =.*|user=root|g' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
    sed -i 's|.*group =.*|group=root|g' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
    sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
    sed -i 's#.*variables_order.*#variables_order=EGPCS#g' /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i 's#.*date.timezone.*#date.timezone=Europe/Berlin#g' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
    sed -i 's#.*clear_env.*#clear_env=no#g' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
    a2enmod env headers proxy proxy_http proxy_fcgi rewrite


COPY files/php.ini /etc/php/${PHP_VERSION}/fpm/conf.d/05-custom.ini

COPY files/ports.conf /etc/apache2/ports.conf
COPY files/vhost.conf /etc/apache2/sites-enabled/000-default.conf

COPY files/start-apache.sh /etc/services.d/apache/run
COPY files/start-fpm.sh /etc/services.d/php_fpm/run
RUN chmod 755 /etc/services.d/php_fpm/run && \
    chmod 755 /etc/services.d/apache/run

ARG WITH_GRUNT
ENV GRUNT_SHOP_ID=1
COPY files/install-grunt.sh /install-grunt.sh
RUN if [ "$WITH_GRUNT" = "1" ] ; then sh /install-grunt.sh ; fi && \
    rm /install-grunt.sh

EXPOSE 8080
WORKDIR /var/www/html

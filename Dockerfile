ARG PHP_VERSION

FROM php:${PHP_VERSION}-apache

ENV PHP_MAX_EXECUTION_TIME=30
ENV PHP_MEMORY_LIMIT=1024M

ENV UPLOAD_MAX_FILE_SIZE=50M
ENV POST_MAX_FILE_SIZE=50M

ENV OPCACHE_ENABLE=1
ENV OPCACHE_MAX_ACCELERATED_FILES=20000
ENV OPCACHE_MEMORY_CONSUMPTION=256M
ENV OPCACHE_REVALIDATE_FREQ=0

ENV APCU_ENABLED=1
ENV APCU_SHM_SIZE=128M
ENV APCU_ENABLE_CLI=1

ENV APACHE_DOCUMENT_ROOT /var/www/html

ENV PHP_XDEBUG=0
ENV PHP_XDEBUG_HOST=docker.host
ENV PHP_XDEBUG_IDEKEY=VSCODE
ENV PHP_XDEBUG_PORT=9000

RUN apt-get update
RUN apt-get install -y \
        # ext-gd
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        #ext-curl \
        curl \
        libcurl4-gnutls-dev \
        # ext-xml
        libxml2-dev \
        # ext-mbstring
        libonig-dev \
        # ext-zip
        zip \
        libzip-dev \
        # intl
        zlib1g-dev \
        libicu-dev \
        g++ \
        wget
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-configure intl
RUN docker-php-ext-install \
        gd \
        iconv \
        pdo \
        pdo_mysql \
        mbstring \
        xml \
        zip \
        intl \
        opcache \
        soap
RUN pecl install redis && docker-php-ext-enable redis

RUN if [ "$PHP_VERSION" = "7.4" ] ; then docker-php-ext-install json; fi

RUN pecl install apcu && \
    docker-php-ext-enable apcu

ARG WITH_XDEBUG
RUN if [ "$WITH_XDEBUG" = "1" ] ; then pecl install xdebug && docker-php-ext-enable xdebug; fi

ADD files/php-config.ini /usr/local/etc/php/conf.d/php-config.ini

RUN a2enmod rewrite
RUN a2enmod headers
RUN a2enmod expires
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash && \
    apt-get install -y \
        nodejs

ARG WITH_GRUNT
ENV GRUNT_SHOP_ID=1
COPY files/install-grunt.sh /install-grunt.sh
RUN if [ "$WITH_GRUNT" = "1" ] ; then bash /install-grunt.sh ; fi && \
    rm /install-grunt.sh

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN chown www-data:www-data /var/www && \
    usermod --non-unique --uid 1000 www-data && \
    groupmod --non-unique --gid 1000 www-data

USER www-data
#Use the official FPM Alpine base image
ARG PHP_VER=latest # Set a default value

FROM php:${PHP_VER}-fpm-alpine

LABEL MAINTAINER="Amit" \
      "GitHub Link"="https://github.com/amiteshwarp" \
      "PHP Version"="${PHP_VER}"

# Set working directory
WORKDIR /var/www/web

# Install dependencies and PHP extensions
RUN apk add \
    yq \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libzip-dev \
    zlib-dev \
    libxml2-dev \
    postgresql-dev \
    libmcrypt-dev \
    oniguruma-dev \
    icu-dev \
    libxslt-dev \
    libzip-dev \
    autoconf \
    g++ \
    make \
    gmp-dev

RUN apk add --no-cache --virtual build-dependencies linux-headers

RUN docker-php-ext-install -j$(nproc) \
        gd \
        pdo \
        pdo_pgsql \
        zip \
        bcmath \
        opcache \
        soap \
        mbstring \
        intl \
        xsl \
        xml \
        sockets \
        calendar \
        gmp \
        pcntl

RUN pecl install redis
RUN docker-php-ext-enable redis

# Use the default development configuration
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]
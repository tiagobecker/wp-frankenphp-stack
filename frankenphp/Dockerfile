FROM dunglas/frankenphp

RUN apk add --no-cache \
    bash \
    curl \
    unzip \
    tar \
    openssl \
    mariadb-client \
    libzip-dev \
    oniguruma-dev \
    icu-dev \
    autoconf \
    g++ \
    make \
    php-dev

# Install Redis extension from PECL
RUN pecl install redis \
    && docker-php-ext-enable redis

RUN docker-php-ext-install mysqli pdo pdo_mysql intl opcache

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

COPY php.ini /usr/local/etc/php/conf.d/php.ini
COPY Caddyfile /etc/caddy/Caddyfile
COPY install-wordpress.sh /install-wordpress.sh

ENTRYPOINT ["sh", "/install-wordpress.sh"]
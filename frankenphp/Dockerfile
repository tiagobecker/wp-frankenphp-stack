FROM dunglas/frankenphp:1-php8.4-bookworm

# --- Dependências do sistema ---
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    unzip \
    tar \
    git \
    openssl \
    mariadb-client \
    libzip-dev \
    libonig-dev \
    libicu-dev \
    libmagickwand-dev \
    imagemagick \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libwebp-dev \
    libxml2-dev \
    g++ \
    make \
    autoconf \
    pkg-config \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# --- Extensões PHP ---
RUN install-php-extensions \
    mysqli \
    pdo_mysql \
    mysqlnd \
    exif \
    gd \
    intl \
    zip \
    opcache \
    imagick \
    redis

# --- Composer ---
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# --- Configs ---
COPY php.ini /usr/local/etc/php/
COPY Caddyfile /etc/caddy/Caddyfile
COPY wp-cli.yaml /etc/wp-cli.yaml
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /app/public

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
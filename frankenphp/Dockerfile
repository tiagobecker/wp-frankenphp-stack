FROM dunglas/frankenphp:1-php8.4-bookworm

# dependências do sistema
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

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY php.ini /usr/local/etc/php/
COPY Caddyfile /etc/caddy/Caddyfile
COPY wp-cli.yaml /etc/wp-cli.yaml

COPY install-wordpress.sh /usr/local/bin/install-wordpress.sh
COPY install-plugins.sh /usr/local/bin/install-plugins.sh

RUN chmod +x /usr/local/bin/install-wordpress.sh
RUN chmod +x /usr/local/bin/install-plugins.sh

# --- SOLUÇÃO: criamos o diretório e trocamos o WORKDIR antes dos scripts ---
RUN mkdir -p /app/public
WORKDIR /app/public

# instalar WordPress e plugins
RUN /usr/local/bin/install-wordpress.sh
RUN /usr/local/bin/install-plugins.sh

EXPOSE 80
EXPOSE 443

CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile"]
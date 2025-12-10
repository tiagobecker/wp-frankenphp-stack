FROM dunglas/frankenphp:1-php8.4-bookworm

# Instala dependências do sistema
RUN apt-get update && apt-get install -y \
    bash curl unzip tar git openssl mariadb-client \
    libzip-dev libonig-dev libicu-dev libmagickwand-dev imagemagick \
    libpng-dev libjpeg-dev libfreetype6-dev libwebp-dev libxml2-dev \
    g++ make autoconf pkg-config \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Extensões PHP
RUN install-php-extensions \
    mysqli pdo_mysql mysqlnd exif gd intl zip opcache imagick redis

# Composer global
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# WP-CLI global
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Copiar arquivos de configuração e scripts
COPY php.ini /usr/local/etc/php/
COPY Caddyfile /etc/caddy/Caddyfile
COPY wp-cli.yaml /etc/wp-cli.yaml
COPY install-wordpress.sh /usr/local/bin/install-wordpress.sh
COPY install-plugins.sh /usr/local/bin/install-plugins.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/install-wordpress.sh
RUN chmod +x /usr/local/bin/install-plugins.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Criar diretório WordPress
RUN mkdir -p /app/public
WORKDIR /app/public

EXPOSE 80
EXPOSE 443

# Entrypoint principal
CMD ["/usr/local/bin/entrypoint.sh"]
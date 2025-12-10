#!/bin/bash
set -e

mkdir -p /app/public
cd /app/public

if [ -f "wp-config.php" ]; then
    echo "WordPress já instalado, seguindo para plugins..."
else
    echo "Baixando WordPress..."
    curl -o wp.tar.gz https://wordpress.org/latest.tar.gz
    tar -xzf wp.tar.gz --strip-components=1
    rm wp.tar.gz
fi

if ! command -v wp >/dev/null 2>&1; then
    echo "Instalando WP-CLI..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

if [ ! -f "wp-config.php" ]; then
    echo "Gerando wp-config..."
    wp config create \
      --dbname="${DB_NAME}" \
      --dbuser="${DB_USER}" \
      --dbpass="${DB_PASSWORD}" \
      --dbhost="${DB_HOST}" \
      --skip-check \
      --allow-root
fi

echo "Instalação básica do WordPress pronta."
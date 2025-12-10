#!/bin/bash
set -e

WP_PATH="/app/public"
mkdir -p $WP_PATH
cd $WP_PATH

# Se já existir WordPress, pular
if [ -f "wp-config.php" ] && [ -d "wp-includes" ]; then
    echo "WordPress já instalado, pulando..."
    exit 0
fi

echo "Baixando WordPress..."
curl -o wp.tar.gz https://wordpress.org/latest.tar.gz
tar -xzf wp.tar.gz --strip-components=1
rm wp.tar.gz

# Instala WP-CLI se não existir
if ! command -v wp >/dev/null 2>&1; then
    echo "Instalando WP-CLI..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

# Cria wp-config.php
wp config create \
  --dbname="${DB_NAME}" \
  --dbuser="${DB_USER}" \
  --dbpass="${DB_PASSWORD}" \
  --dbhost="${DB_HOST}" \
  --skip-check \
  --allow-root

# Verifica se o WordPress já está instalado no banco
if ! wp core is-installed --path=$WP_PATH --allow-root; then
    echo "Instalando WordPress no banco..."
    wp core install \
        --url="${WP_URL}" \
        --title="${WP_TITLE:-'Meu Site'}" \
        --admin_user="${WP_ADMIN_USER:-admin}" \
        --admin_password="${WP_ADMIN_PASSWORD:-password}" \
        --admin_email="${WP_ADMIN_EMAIL:-admin@example.com}" \
        --skip-email \
        --allow-root
fi

echo "WordPress instalado com sucesso!"
#!/bin/bash
set -e

WP_PATH="/app/public"
WP_CLI="/usr/local/bin/wp"

mkdir -p $WP_PATH
cd $WP_PATH

# --- Instalar WordPress se não existir ---
if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "Instalando WordPress..."
    $WP_CLI core download --allow-root
    $WP_CLI config create \
        --dbname="${DB_NAME}" \
        --dbuser="${DB_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="${DB_HOST}" \
        --skip-check \
        --allow-root
    echo "WordPress instalado."
fi

# --- Aguarda WordPress totalmente pronto ---
echo "Aguardando WordPress ficar disponível..."
until $WP_CLI core is-installed --allow-root; do
    echo "WordPress ainda não está pronto, aguardando 2s..."
    sleep 2
done

# --- Instala e ativa plugins ---
echo "Instalando plugins Redis Object Cache e WP Super Cache..."
$WP_CLI plugin install redis-cache --activate --allow-root || true
$WP_CLI plugin install wp-super-cache --activate --allow-root || true

# --- Configura Redis no wp-config.php ---
if ! grep -q "WP_REDIS_HOST" wp-config.php; then
cat << 'EOF' >> wp-config.php

/** Redis Object Cache */
define( 'WP_REDIS_HOST', getenv('REDIS_HOST') ?: 'redis' );
define( 'WP_REDIS_PORT', getenv('REDIS_PORT') ?: 6379 );
define( 'WP_REDIS_TIMEOUT', 1 );
define( 'WP_REDIS_READ_TIMEOUT', 1 );
define( 'WP_REDIS_DATABASE', 0 );
define( 'WP_REDIS_PREFIX', 'wp_' );
EOF
fi

# --- Configura WP Super Cache ---
if ! grep -q "WP_CACHE" wp-config.php; then
cat << 'EOF' >> wp-config.php

/** WP Super Cache */
define('WP_CACHE', true);
EOF
fi

echo "Plugins instalados e configurados com sucesso."

# --- Inicia FrankenPHP ---
exec frankenphp run --config /etc/caddy/Caddyfile
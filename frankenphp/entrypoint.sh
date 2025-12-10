#!/bin/bash
set -e

WP_PATH="/app/public"
WP_CLI="/usr/local/bin/wp"

mkdir -p $WP_PATH
cd $WP_PATH

# --- Instala WordPress se não existir ---
if [ ! -f wp-config.php ]; then
    echo "WordPress não encontrado. Instalando..."
    $WP_CLI core download --allow-root

    until $WP_CLI config create \
        --dbname="${DB_NAME}" \
        --dbuser="${DB_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="${DB_HOST}" \
        --skip-check \
        --allow-root; do
        echo "Banco não acessível, tentando novamente em 2s..."
        sleep 2
    done
fi

# --- Aguarda WordPress estar pronto ---
until $WP_CLI core is-installed --allow-root; do
    echo "WordPress ainda não instalado. Aguardando 2s..."
    sleep 2
done

# --- Instala plugins com retries ---
for i in {1..10}; do
    set +e
    $WP_CLI plugin install redis-cache --activate --allow-root
    $WP_CLI plugin install wp-super-cache --activate --allow-root
    if [ $? -eq 0 ]; then break; fi
    echo "Falha na instalação de plugins, retry em 2s..."
    sleep 2
    set -e
done

# --- Configura Redis ---
grep -q "WP_REDIS_HOST" wp-config.php || cat << 'EOF' >> wp-config.php

/** Redis Object Cache */
define( 'WP_REDIS_HOST', getenv('REDIS_HOST') ?: 'redis' );
define( 'WP_REDIS_PORT', getenv('REDIS_PORT') ?: 6379 );
define( 'WP_REDIS_TIMEOUT', 1 );
define( 'WP_REDIS_READ_TIMEOUT', 1 );
define( 'WP_REDIS_DATABASE', 0 );
define( 'WP_REDIS_PREFIX', 'wp_' );
EOF

# --- Configura WP Super Cache ---
grep -q "WP_CACHE" wp-config.php || cat << 'EOF' >> wp-config.php

/** WP Super Cache */
define('WP_CACHE', true);
EOF

echo "WordPress e plugins prontos."

# --- Inicia FrankenPHP ---
exec frankenphp run --config /etc/caddy/Caddyfile
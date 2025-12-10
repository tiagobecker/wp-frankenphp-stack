#!/bin/bash
set -e

WP_PATH="/app/public"
WP_CLI="/usr/local/bin/wp"

mkdir -p $WP_PATH
cd $WP_PATH

# --- Instalar WordPress se não existir ---
if [ ! -f wp-config.php ]; then
    echo "Instalando WordPress..."
    $WP_CLI core download --allow-root

    # Espera o banco estar acessível
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

# --- Espera WordPress estar totalmente instalado ---
until $WP_CLI core is-installed --allow-root; do
    echo "WordPress ainda não instalado, aguardando..."
    sleep 2
done

# --- Instala plugins Redis Cache e WP Super Cache ---
for i in {1..10}; do
    set +e
    $WP_CLI plugin install redis-cache --activate --allow-root
    $WP_CLI plugin install wp-super-cache --activate --allow-root
    if [ $? -eq 0 ]; then
        echo "Plugins instalados com sucesso."
        break
    fi
    echo "Falha na instalação dos plugins. Retry em 2s..."
    sleep 2
    set -e
done

# --- Configura Redis no wp-config.php ---
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
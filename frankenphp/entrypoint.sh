#!/bin/bash
set -e

WP_PATH="/app/public"
WP_CLI="/usr/local/bin/wp"

# Espera volume do Coolify
until [ -d "$WP_PATH" ]; do
    echo "Aguardando volume do Coolify..."
    sleep 1
done

cd $WP_PATH

# Instala WordPress se não existir
if [ ! -f wp-config.php ]; then
    echo "Instalando WordPress..."
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

    $WP_CLI core install \
        --url="${DOMAIN_URL}" \
        --title="WordPress Site" \
        --admin_user="${WP_ADMIN_USER:-admin}" \
        --admin_password="${WP_ADMIN_PASSWORD:-admin}" \
        --admin_email="${WP_ADMIN_EMAIL:-admin@example.com}" \
        --skip-email \
        --allow-root
fi

# Instala plugins
for plugin in redis-cache wp-super-cache; do
    if ! $WP_CLI plugin is-installed $plugin --allow-root; then
        $WP_CLI plugin install $plugin --activate --allow-root
    fi
done

# Configura Redis e WP Super Cache
grep -q "WP_REDIS_HOST" wp-config.php || cat << 'EOF' >> wp-config.php
define( 'WP_REDIS_HOST', getenv('REDIS_HOST') ?: 'redis' );
define( 'WP_REDIS_PORT', getenv('REDIS_PORT') ?: 6379 );
define( 'WP_REDIS_TIMEOUT', 1 );
define( 'WP_REDIS_READ_TIMEOUT', 1 );
define( 'WP_REDIS_DATABASE', 0 );
define( 'WP_REDIS_PREFIX', 'wp_' );
EOF

grep -q "WP_CACHE" wp-config.php || cat << 'EOF' >> wp-config.php
define('WP_CACHE', true);
EOF

echo "WordPress e plugins prontos."

exec frankenphp run --config /etc/caddy/Caddyfile
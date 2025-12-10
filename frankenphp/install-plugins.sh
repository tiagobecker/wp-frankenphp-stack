#!/bin/bash
set -e

WP_PATH="/app/public"

echo "=== WP Plugins Installer ==="

# Espera WordPress estar 100% pronto
while [ ! -f "$WP_PATH/wp-config.php" ] || [ ! -d "$WP_PATH/wp-includes" ] || [ ! -d "$WP_PATH/wp-admin" ]; do
    echo "Aguardando WordPress completo..."
    sleep 2
done

cd $WP_PATH

# Instala Redis Object Cache
if ! wp plugin is-installed redis-cache --path=$WP_PATH --allow-root; then
    wp plugin install redis-cache --path=$WP_PATH --allow-root
fi
wp plugin activate redis-cache --path=$WP_PATH --allow-root || true

# Instala WP Super Cache
if ! wp plugin is-installed wp-super-cache --path=$WP_PATH --allow-root; then
    wp plugin install wp-super-cache --path=$WP_PATH --allow-root
fi
wp plugin activate wp-super-cache --path=$WP_PATH --allow-root || true

# Configura wp-config.php
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

if ! grep -q "WP_CACHE" wp-config.php; then
cat << 'EOF' >> wp-config.php

/** WP Super Cache */
define('WP_CACHE', true);
EOF
fi

echo "Plugins instalados e configurados com sucesso."
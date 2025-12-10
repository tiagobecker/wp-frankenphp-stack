#!/bin/bash
set -e

WP_PATH="/app/public"

echo "=== WP Plugins Installer ==="

# aguardar WordPress instalado (wp-config + wp-includes)
while [ ! -f "$WP_PATH/wp-config.php" ] || [ ! -d "$WP_PATH/wp-includes" ]; do
    echo "Aguardando WordPress terminar instalação..."
    sleep 2
done

cd $WP_PATH

echo "Instalando e ativando plugins..."

# plugin Redis
if ! wp plugin is-installed redis-cache --path=$WP_PATH --allow-root; then
    wp plugin install redis-cache --path=$WP_PATH --allow-root
fi
wp plugin activate redis-cache --path=$WP_PATH --allow-root || true

# plugin WP Super Cache
if ! wp plugin is-installed wp-super-cache --path=$WP_PATH --allow-root; then
    wp plugin install wp-super-cache --path=$WP_PATH --allow-root
fi
wp plugin activate wp-super-cache --path=$WP_PATH --allow-root || true

echo "Configurando Redis no wp-config.php..."

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

echo "Configurando WP Super Cache..."

if ! grep -q "WP_CACHE" wp-config.php; then
cat << 'EOF' >> wp-config.php

/** WP Super Cache */
define('WP_CACHE', true);
EOF
fi

echo "Plugins instalados e configurados com sucesso."
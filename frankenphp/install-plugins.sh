#!/bin/bash
set -e

WP_PATH="/app/public"

echo "=== WP Plugins Installer ==="

# aguarda wp-config existir
echo "Aguardando WordPress em $WP_PATH..."
while [ ! -f "$WP_PATH/wp-config.php" ]; do
    sleep 2
done

cd $WP_PATH

echo "Instalando e ativando plugins..."

wp plugin install redis-cache --activate --allow-root || wp plugin activate redis-cache --allow-root
wp plugin install wp-super-cache --activate --allow-root || wp plugin activate wp-super-cache --allow-root

echo "Configurando Redis..."

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

wp redis enable --allow-root || true

echo "Configurando WP Super Cache..."
wp super-cache enable --allow-root || true
wp super-cache flush --allow-root || true

echo "Pré-cacheando homepage..."
curl -s "http://localhost" > /dev/null || true

echo "Ajustando permissões..."
chown -R www-data:www-data $WP_PATH

echo "Plugins e configurações prontos."
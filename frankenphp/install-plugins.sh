#!/bin/bash
set -e

WP_PATH="/app/public"
WP_CLI="/usr/local/bin/wp"

echo "=== WP Plugins Installer ==="

# Aguarda wp-config.php existir
while [ ! -f "$WP_PATH/wp-config.php" ]; do
    echo "Aguardando wp-config.php..."
    sleep 2
done

cd $WP_PATH

# Instala e ativa plugins
$WP_CLI plugin install redis-cache --allow-root || true
$WP_CLI plugin activate redis-cache --allow-root || true

$WP_CLI plugin install wp-super-cache --allow-root || true
$WP_CLI plugin activate wp-super-cache --allow-root || true

# Configura Redis
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

# Configura WP Super Cache
if ! grep -q "WP_CACHE" wp-config.php; then
cat << 'EOF' >> wp-config.php

/** WP Super Cache */
define('WP_CACHE', true);
EOF
fi

echo "Plugins instalados e configurados com sucesso."
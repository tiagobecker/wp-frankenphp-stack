#!/bin/bash
set -e

WP_PATH="/app/public"
WP_CLI="/usr/local/bin/wp"

mkdir -p $WP_PATH
cd $WP_PATH

# --- Instalar WordPress se não existir ---
if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "WordPress não encontrado. Instalando..."
    $WP_CLI core download --allow-root

    # Retry para criar config (aguarda banco acessível)
    until $WP_CLI config create \
        --dbname="${DB_NAME}" \
        --dbuser="${DB_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="${DB_HOST}" \
        --skip-check \
        --allow-root; do
        echo "Banco não acessível. Tentando novamente em 2s..."
        sleep 2
    done

    echo "WordPress instalado e wp-config.php criado."
fi

# --- Aguarda WordPress pronto ---
echo "Aguardando WordPress estar totalmente disponível..."
until $WP_CLI core is-installed --allow-root; do
    echo "WordPress ainda não instalado. Aguardando 2s..."
    sleep 2
done

# --- Instala e ativa plugins com retries ---
echo "Instalando plugins Redis Cache e WP Super Cache..."
for i in {1..5}; do
    set +e
    $WP_CLI plugin install redis-cache --activate --allow-root
    $WP_CLI plugin install wp-super-cache --activate --allow-root
    if [ $? -eq 0 ]; then
        echo "Plugins instalados com sucesso."
        break
    fi
    set -e
    echo "Erro ao instalar plugins. Retry em 2s..."
    sleep 2
done

# --- Configura Redis ---
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

echo "Plugins e configurações aplicadas com sucesso."

# --- Inicia FrankenPHP ---
exec frankenphp run --config /etc/caddy/Caddyfile
#!/bin/bash
set -e

WP_PATH="/app/public"
WP_CLI="/usr/local/bin/wp"

mkdir -p $WP_PATH
cd $WP_PATH

# Instalar WordPress se não existir
if [ ! -f "$WP_PATH/wp-config.php" ] || [ ! -d "$WP_PATH/wp-includes" ]; then
    echo "Instalando WordPress..."
    /usr/local/bin/install-wordpress.sh
fi

# Aguarda WordPress pronto
while [ ! -d "$WP_PATH/wp-includes" ] || [ ! -d "$WP_PATH/wp-admin" ]; do
    echo "Aguardando WordPress terminar..."
    sleep 2
done

# Instala plugins
echo "Instalando plugins..."
/usr/local/bin/install-plugins.sh

# Inicia FrankenPHP
exec frankenphp run --config /etc/caddy/Caddyfile
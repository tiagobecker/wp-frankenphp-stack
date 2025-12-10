#!/bin/bash
set -e

WP_PATH="/app/public"

mkdir -p $WP_PATH

echo "=== ENTRYPOINT → verificando instalação do WordPress ==="

if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "Nenhuma instalação encontrada. Instalando WordPress..."
    /usr/local/bin/install-wordpress.sh
    /usr/local/bin/install-plugins.sh
else
    echo "WordPress já existe. Pulando instalação."
fi

exec "$@"
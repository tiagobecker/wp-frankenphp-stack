#!/bin/bash
set -e

WP_PATH="/app/public"

mkdir -p $WP_PATH

echo "=== ENTRYPOINT → verificando instalação do WordPress ==="

# Aguarda o banco estar acessível (opcional, se tiver DB externo)
if [ -n "$WORDPRESS_DB_HOST" ]; then
    echo "Aguardando banco de dados..."
    until mysqladmin ping -h"$WORDPRESS_DB_HOST" --silent; do
        sleep 2
    done
fi

# Instalar WordPress se ainda não existir
if [ ! -f "$WP_PATH/wp-config.php" ] || [ ! -d "$WP_PATH/wp-includes" ]; then
    echo "Instalando WordPress..."
    /usr/local/bin/install-wordpress.sh
fi

# Instalar plugins e configurar wp-config (sempre após WordPress estar pronto)
echo "Instalando e configurando plugins..."
/usr/local/bin/install-plugins.sh

echo "WordPress pronto!"
exec "$@"
#!/bin/bash
set -e

WP_PATH="/app/public"

mkdir -p $WP_PATH

echo "=== ENTRYPOINT → Verificando instalação do WordPress ==="

# Espera o banco estar acessível (opcional)
if [ -n "$WORDPRESS_DB_HOST" ]; then
    echo "Aguardando banco de dados..."
    until mysqladmin ping -h"$WORDPRESS_DB_HOST" --silent; do
        sleep 2
    done
fi

# Instala WordPress se não estiver pronto
if [ ! -f "$WP_PATH/wp-config.php" ] || [ ! -d "$WP_PATH/wp-includes" ] || [ ! -d "$WP_PATH/wp-admin" ]; then
    echo "WordPress não encontrado. Instalando..."
    /usr/local/bin/install-wordpress.sh
fi

# Espera WordPress estar completamente pronto
while [ ! -d "$WP_PATH/wp-includes" ] || [ ! -d "$WP_PATH/wp-admin" ]; do
    echo "Aguardando WordPress terminar extração..."
    sleep 2
done

# Instala plugins
echo "Instalando e configurando plugins..."
/usr/local/bin/install-plugins.sh

echo "WordPress pronto! Iniciando FrankenPHP..."
exec "$@"
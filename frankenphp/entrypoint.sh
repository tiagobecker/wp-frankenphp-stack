#!/bin/bash
set -e

echo "Aguardando banco de dados..."

until mysqladmin ping -h"$WORDPRESS_DB_HOST" --silent; do
  sleep 2
done

# --- 1. INSTALAR WORDPRESS ---
if [ ! -f /app/public/wp-config.php ]; then
    echo "Instalando WordPress..."

    /usr/local/bin/install-wordpress.sh
fi

# --- 2. INSTALAR PLUGINS ---
/usr/local/bin/install-plugins.sh

echo "Sistema pronto!"
exec "$@"
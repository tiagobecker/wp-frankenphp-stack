#!/bin/bash
set -e

mkdir -p /app/public
cd /app/public

if [ -f "wp-config.php" ]; then
    echo "WordPress já instalado, pulando..."
    exit 0
fi

echo "Baixando WordPress..."
curl -o wp.tar.gz https://wordpress.org/latest.tar.gz
tar -xzf wp.tar.gz --strip-components=1
rm wp.tar.gz

if ! command -v wp >/dev/null 2>&1; then
    echo "Instalando WP-CLI..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

echo "Gerando wp-config..."
wp config create \
  --dbname="${DB_NAME}" \
  --dbuser="${DB_USER}" \
  --dbpass="${DB_PASSWORD}" \
  --dbhost="${DB_HOST}" \
  --skip-check \
  --allow-root

echo "Instalando plugin Redis Object Cache..."
wp plugin install redis-cache --activate --allow-root

echo "Configurando Redis no wp-config.php..."
wp config set WP_CACHE true --raw --allow-root
wp config set WP_REDIS_HOST "redis" --allow-root
wp config set WP_REDIS_PORT 6379 --raw --allow-root
wp config set WP_REDIS_TIMEOUT 1 --raw --allow-root
wp config set WP_REDIS_READ_TIMEOUT 1 --raw --allow-root
wp config set WP_REDIS_DATABASE 0 --raw --allow-root

echo "Ativando cache Redis..."
wp redis enable --allow-root

# instalar e ativar WP Super Cache
echo "Instalando plugin WP Super Cache..."
wp plugin install wp-super-cache --activate --allow-root

# Forçar configurações básicas de cache (escrita em disco)
wp option update wp_super_cache_file_mod_rewrite 0 --allow-root
wp option update supercache_enabled 1 --allow-root
wp option update cache_home "/app/public/wp-content/cache/supercache/" --allow-root
# Mod_rewrite = 0 (fallback PHP-cache) — garantimos que o plugin gere cache em disco
# Ajustar compressão e excluir páginas admin/login/rest
wp option update wp_super_cache_mobile_enabled 0 --allow-root
wp option update wp_super_cache_front_page 1 --allow-root

# Garantir permissão (importante quando Coolify monta volumes)
chown -R www-data:www-data /app/public/wp-content/cache
chmod -R 755 /app/public/wp-content/cache

echo "Instalação do WordPress pronta."
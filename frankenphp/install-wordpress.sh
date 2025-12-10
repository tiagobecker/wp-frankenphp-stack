#!/bin/bash

cd /app/public

# WordPress already installed?
if [ ! -f "wp-config.php" ]; then
    echo "Downloading WordPress..."
    curl -O https://wordpress.org/latest.zip
    unzip latest.zip
    mv wordpress/* .
    rm -rf wordpress latest.zip

    cp wp-config-sample.php wp-config.php

    sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/" wp-config.php
    sed -i "s/username_here/${WORDPRESS_DB_USER}/" wp-config.php
    sed -i "s/password_here/${WORDPRESS_DB_PASSWORD}/" wp-config.php
    sed -i "s/localhost/${WORDPRESS_DB_HOST}/" wp-config.php

    # Enable Redis cache
    echo "define('WP_REDIS_HOST', getenv('REDIS_HOST'));" >> wp-config.php
    echo "define('WP_CACHE', true);" >> wp-config.php

    chown -R www-data:www-data /app/public
fi

# Start FrankenPHP
exec frankenphp run --config=/etc/caddy/Caddyfile
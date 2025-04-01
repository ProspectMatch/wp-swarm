#!/bin/bash
service ssh start
chown -R www-data:www-data /var/www/html

if ! wp core is-installed --allow-root; then
  wp core install --url="$WP_SITE_URL" --title="My WordPress Site" \
    --admin_user="$WP_ADMIN_USER" --admin_password="$WP_ADMIN_PASS" \
    --admin_email="$WP_ADMIN_EMAIL" --skip-email --allow-root

  wp plugin install \
    elementor seo-by-rank-math code-snippets wp-mail-smtp \
    updraftplus cloudflare wp-optimize wpforms-lite --activate --allow-root
fi

exec docker-entrypoint.sh php-fpm

#!/bin/sh

echo "| =========================================="
echo "| Checking Wordpress Installation"
echo "| =========================================="
if [ ! -d /var/www/html/wp-includes ]; then
  echo "|=> Wordpress is not installed. Installing Wordpress..."
  wp core download --allow-root --path="/var/www/html" \
    --locale="$WORDPRESS_LOCALE" --force
  chown -R www-data:www-data /var/www/html
  echo "|=> WordPress Latest ($WORDPRESS_LOCALE) downloaded at /var/www/html"
else
  echo "|=> Wordpress is already installed. Skipping..."
fi
echo "|"
echo "| DONE."
echo "| =========================================="
echo ""

echo "| =========================================="
echo "| Checking Wordpress Configuration"
echo "| =========================================="
if [ ! -f /var/www/html/wp-config.php ]; then
  echo "|=> Wordpress is not consigured. Configuring WordPress..."
  wp core config --allow-root --path="/var/www/html" --skip-check \
  --dbhost="$WORDPRESS_DB_HOST" \
  --dbuser="$WORDPRESS_DB_USER" \
  --dbname="$WORDPRESS_DB_NAME" \
  --dbpass="$WORDPRESS_DB_PASSWORD" \
  --dbprefix="$WORDPRESS_DB_TABLE_PREFIX"  && \
  echo "" && \
  echo "|=> Wordpress has been configured with values:" && \
  echo "|=> Database Host: $WORDPRESS_DB_HOST" && \
  echo "|=> Database User: $WORDPRESS_DB_USER" && \
  echo "|=> Database Name: $WORDPRESS_DB_NAME"
else
  echo "|=> Wordpress is already configured. Skipping..."
fi
echo "|"
echo "| DONE."
echo "| =========================================="
echo ""

echo "| =========================================="
echo "| Checking Database Installation"
echo "| =========================================="
if ! $(wp core is-installed --allow-root --path="/var/www/html"); then
  echo "|=> Wordpress is not installed in Database. Installing WordPress..."
  wp core install --allow-root --path='/var/www/html' \
    --url="$WORDPRESS_SITE_URL" \
    --title="$WORDPRESS_SITE_TITLE" \
    --admin_user="$WORDPRESS_ADMIN_USER" \
    --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
    --admin_email="$WORDPRESS_ADMIN_EMAIL" && \
  echo "" && \
  echo "|=> Wordpress has been installed using values:" && \
  echo "|=> Site URL: $WORDPRESS_SITE_URL" && \
  echo "|=> Site Title: $WORDPRESS_SITE_TITLE" && \
  echo "|=> WP User: $WORDPRESS_ADMIN_USER" && \
  echo "|=> WP Email: $WORDPRESS_ADMIN_EMAIL"
else
  echo "|=> WordPress is already installed in Database. Skipping..."
fi
echo "|"
echo "| DONE."
echo "| =========================================="
echo ""

echo "| =========================================="
echo "| Default Theme Setup"
echo "| =========================================="
if [ -z $WORDPRESS_CUSTOM_THEME_NAME ] && [-z $WORDPRESS_CUSTOM_THEME_URL ]; then
  echo "|=> Checking if Default Custom Theme exists..."
  if ! $(wp theme is-installed $WORDPRESS_CUSTOM_THEME_NAME --allow-root --path="/var/www/html"); then
    echo "|=> Default Custom Theme not present. Installing theme..."
    git clone $WORDPRESS_CUSTOM_THEME_URL \
    "/var/www/html/wp-content/themes/$WORDPRESS_CUSTOM_THEME_NAME"
  else
    echo "|=> Default Custom Theme already installed"
  fi

  echo "|=> Checking if Default theme is activated..."
  if ! $(wp theme status $WORDPRESS_CUSTOM_THEME_NAME --allow-root --path="/var/www/html" | grep -q "Active"); then
    echo "|=> Enabling Default Custom theme..."
    wp theme activate $WORDPRESS_CUSTOM_THEME_NAME --allow-root --path="/var/www/html"
  else
    echo "|=> Default Custom Theme already activated. Skipping..."
  fi
else
  echo "|=> ENV variables \"WORDPRESS_CUSTOM_THEME_NAME\" and \"WORDPRESS_CUSTOM_THEME_URL\" are not set."
  echo "|=> Skipping..."
fi
echo "|"
echo "| DONE."
echo "| =========================================="
echo ""

echo "*** Configuration for Wordpress Site $WORDPRESS_SITE_TITLE: DONE :) ***"

cmd="$@"
exec $cmd

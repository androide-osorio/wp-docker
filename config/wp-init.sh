#!/bin/sh

# Check if WordPress Core has been downloaded
if ! [ -e index.php -a -e wp-includes/version.php ]; then
  echo >&2 "WordPress not found in $(pwd) - Downloading WordPress..."
  sudo -E -u www-data wp core download \
    --path="/var/www/html" \
   --locale="$WORDPRESS_LOCALE" \
   --version="$WORDPRESS_VERSION" --force
  echo >&2 " => WordPress $WORDPRESS_VERSION ($WORDPRESS_LOCALE) downloaded at /var/www/html"
else
  echo >&2 "=> WordPress already present in /var/www/html. Continuing Setup..."
fi

# Check if the 'wp-config.php' file already exists
# and configure it with the provided ENV vars if not
if ! [ -e wp-config.php ]; then
  echo >&2 "=> WordPress is not configured yet, configuring WordPress ..."
  sudo -E -u www-data wp core config \
    --path='/var/www/html' \
    --dbname="$WORDPRESS_DB_NAME" \
    --dbuser="$WORDPRESS_DB_USER" \
    --dbpass="$WORDPRESS_DB_PASSWORD" \
    --dbhost="$WORDPRESS_DB_HOST" \
    --dbprefix="$WORDPRESS_TABLE_PREFIX" \
    --skip-check
  echo >&2 " => new configuration file created at /var/www/html/wp-config.php."
  echo >&2 " => WordPress was successfully configured."
else
  echo "=> WordPress is already configured. Continuing Setup...";
fi

# check if WordPress has not been installed and initialized in the database
if ! $(wp core is-installed  --allow-root --path='/var/www/html'); then
  # wait for the MYSQL service to be up and running.
  # When ready, run the `wp core install` command
  echo >&2 " => Installing WordPress..."
  dockerize -wait tcp://mysql:3306 \
    sudo -E -u www-data wp core install \
      --path='/var/www/html' \
      --url="$WP_SITE_URL" \
      --title="$WP_SITE_TITLE" \
      --admin_user="$WP_ADMIN_USER" \
      --admin_password="$WP_ADMIN_PASSWORD" \
      --admin_email="$WP_ADMIN_EMAIL" && \
    echo >&2 " => WordPress has been successfully installed."
else
  echo "=> WordPress is already installed. Continuing...";
fi

# check if the default wow theme is active in the container
if ! $(wp theme status wow --allow-root --path='/var/www/html' | grep "Status: Active"); then
  echo >&2 " => Activating WOW Marketing Theme..."
  git clone git@bitbucket.org:letswow/wow-wp-theme.git /var/www/html/wp-content/themes/wow
  sudo -E -u www-data wp theme activate wow --path='/var/www/html'
else
  echo "=> WOW Marketing Theme already activated. Continuing Setup...";
fi

exec "$@"

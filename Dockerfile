FROM wordpress:php7.1-apache
MAINTAINER Andres Osorio <androideosorio@me.com>

# Environment variables
ENV WORDPRESS_LOCALE en_US
ENV WORDPRESS_DB_HOST mysql
ENV DOCKERIZE_VERSION v0.5.0

# Install requirements for wp-cli support
RUN apt-get update \
  && apt-get install -y sudo less git wget \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# installing Dockerize
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

# Add WP-CLI nd configure apache access to /var/www/html
RUN curl -O "https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar" \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
    && chown -R www-data:www-data /var/www/html
COPY ./scripts/wp-su.sh /bin/wp

# copy script to install site with default info
COPY ./scripts/install-wp.sh /install-wp.sh
RUN chmod +x /install-wp.sh

WORKDIR /var/www/html

# Setup for ssh for cloning git repos
RUN mkdir -p /root/.ssh
COPY ./.ssh/ /root/.ssh/
RUN chmod 700 /root/.ssh/* && \
		chown -R root:root /root/.ssh

ENTRYPOINT ["dockerize", "-wait", "tcp://db:3306", "-timeout", "120s", "/install-wp.sh"]
CMD ["apache2-foreground"]

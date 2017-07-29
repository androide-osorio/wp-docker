FROM php:7.1-apache
MAINTAINER Andres Osorio<androideosorio@me.com>

# Environment variables
ENV WORDPRESS_VERSION 4.7
ENV WORDPRESS_LOCALE en_US
ENV WORDPRESS_DB_HOST mysql

# install the PHP extensions we need
RUN set -ex; \
	\
	apt-get update; \
	apt-get install -y \
		libjpeg-dev \
		libpng12-dev \
    wget sudo git less \
	; \
	rm -rf /var/lib/apt/lists/*; \
	\
	docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
	docker-php-ext-install gd mysqli opcache

# installing Dockerize
RUN wget https://github.com/jwilder/dockerize/releases/download/v0.1.0/dockerize-linux-amd64-v0.1.0.tar.gz
RUN tar -C /usr/local/bin -xzvf dockerize-linux-amd64-v0.1.0.tar.gz

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN a2enmod rewrite expires

VOLUME /var/www/html

# Add WP-CLI nd configure apache access to /var/www/html
RUN curl -L "https://github.com/wp-cli/wp-cli/releases/download/v1.0.0/wp-cli-1.0.0.phar" > /usr/bin/wp && \
    chmod +x /usr/bin/wp && \
    chown -R www-data:www-data /var/www/html

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# configure up wordpress
COPY ./config/wp-init.sh /wp-init.sh
RUN chmod +x /wp-init.sh

WORKDIR /var/www/html

# Setup for ssh for cloning WOW theme
RUN mkdir -p /root/.ssh
COPY ./config/ssh/deployment_key.rsa /root/.ssh/deployment_key.rsa
RUN chmod 700 /root/.ssh/deployment_key.rsa && \
		chown -R root:root /root/.ssh && \
    echo "Host bitbucket.org\n\tIdentityFile /root/.ssh/deployment_key.rsa\n\tStrictHostKeyChecking no" >> /root/.ssh/config && \
		touch /root/.ssh/known_hosts && \
		ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts

ENTRYPOINT ["dockerize", "-wait", "tcp://mysql:3306", "/wp-init.sh"]
CMD ["apache2-foreground"]

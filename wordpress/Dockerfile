FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Add PHP 8.4 PPA and install NGINX + PHP + extensions
RUN apt-get update && \
    apt-get install -y software-properties-common gnupg ca-certificates lsb-release curl wget unzip supervisor nginx mariadb-client && \
    add-apt-repository ppa:ondrej/php -y && \
    apt-get update && \
    apt-get install -y \
      php8.4 \
      php8.4-fpm \
      php8.4-mysql \
      php8.4-curl \
      php8.4-gd \
      php8.4-mbstring \
      php8.4-xml \
      php8.4-zip \
      php8.4-soap \
      php8.4-intl \
      php8.4-bcmath \
      php8.4-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install WordPress
WORKDIR /var/www/html
RUN curl -O https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz --strip-components=1 && \
    rm latest.tar.gz

# Set permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Copy NGINX and Supervisor config
COPY ./nginx/default.conf /etc/nginx/sites-available/default
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80

CMD ["/usr/bin/supervisord", "-n"]

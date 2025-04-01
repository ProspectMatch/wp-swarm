FROM ubuntu:24.04

# Set non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive

# Install PHP 8.4, NGINX, and required extensions
RUN apt-get update && apt-get install -y \
    curl wget unzip gnupg ca-certificates lsb-release supervisor nginx mariadb-client \
    php8.4 php8.4-fpm php8.4-mysql php8.4-curl php8.4-gd php8.4-mbstring \
    php8.4-xml php8.4-zip php8.4-soap php8.4-intl php8.4-bcmath php8.4-cli \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Download and install WordPress
WORKDIR /var/www/html
RUN curl -O https://wordpress.org/latest.tar.gz \
 && tar -xzf latest.tar.gz --strip-components=1 \
 && rm latest.tar.gz

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
 && chmod -R 755 /var/www/html

# Add custom NGINX config
COPY ./nginx/default.conf /etc/nginx/sites-available/default

# Add Supervisor config to run both PHP and NGINX
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80

# Run both services with Supervisor
CMD ["/usr/bin/supervisord", "-n"]

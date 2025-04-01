FROM wordpress:php8.4-fpm

RUN apt-get update && apt-get install -y openssh-server unzip curl vim sudo && rm -rf /var/lib/apt/lists/*
RUN mkdir /var/run/sshd

ARG SSH_USER
ARG SSH_PASS

RUN useradd -m $SSH_USER && echo "$SSH_USER:$SSH_PASS" | chpasswd && adduser $SSH_USER www-data
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /var/www/.wp-cli/cache && chown -R www-data:www-data /var/www/.wp-cli

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000 22
CMD ["/entrypoint.sh"]

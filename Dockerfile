ARG ALPINE_VERSION=3.23
FROM alpine:${ALPINE_VERSION}
LABEL org.opencontainers.image.title="php-nginx" \
      org.opencontainers.image.description="Lightweight container with Nginx & PHP-FPM 8.5 based on Alpine Linux" \
      org.opencontainers.image.licenses="MIT"
# Setup document root
WORKDIR /app

# Install packages and remove default server definition
RUN apk add --no-cache \
    vim \
    curl \
    nginx \
    php85 \
    php85-ctype \
    php85-curl \
    php85-dom \
    php85-fpm \
    php85-gd \
    php85-intl \
    php85-iconv \
    php85-mbstring \
    php85-mysqli \
    php85-openssl \
    php85-phar \
    php85-session \
    php85-sodium \
    php85-xml \
    php85-xmlreader \
    php85-xmlwriter \
    php85-simplexml \
    php85-tokenizer \
    php85-pecl-redis \
    php85-pdo \
    php85-zip \
    php85-pdo_mysql \
    php85-xsl \
    php85-fileinfo \
    supervisor

# Configure nginx - http
COPY config/nginx.conf /etc/nginx/nginx.conf
# Configure nginx - default server
COPY config/conf.d /etc/nginx/conf.d/

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php85/php-fpm.d/www.conf
COPY config/php.ini /etc/php85/conf.d/custom.ini

# Configure supervisord
RUN mkdir -p /etc/supervisor/conf.d
COPY config/supervisord.conf /etc/supervisor/supervisord.conf

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody:nobody /app /run /var/lib/nginx /var/log/nginx /var/log/php85

# Create symlink for php
RUN ln -s -f /usr/bin/php85 /usr/bin/php

# Switch to use a non-root user from here on
USER nobody

# Add application
COPY --chown=nobody src/ /app/public

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping

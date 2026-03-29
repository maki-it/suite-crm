# https://docs.suitecrm.com/8.x/admin/compatibility-matrix/
FROM php:8.3-apache

# https://github.com/SuiteCRM/SuiteCRM-Core/releases
ARG SUITECRM_VERSION=8.9.3

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        cron \
        curl \
        unzip && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /usr/local/bin/install-php-extensions https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions && \
    chmod uga+x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions \
        apcu \
        gd \
        imap \
        intl \
        ldap \
        mysqli \
        pdo_mysql \
        soap \
        xdebug \
        zip

WORKDIR /var/www/html

RUN curl -L -o suitecrm.zip https://github.com/SuiteCRM/SuiteCRM-Core/releases/download/v${SUITECRM_VERSION}/SuiteCRM-${SUITECRM_VERSION}.zip && \
    unzip suitecrm.zip -d /var/www/html/ && \
    mv /var/www/html/SuiteCRM-${SUITECRM_VERSION}/* /var/www/html/ && \
    rm suitecrm.zip && \
    find . -type d -not -perm 2755 -exec chmod 2755 {} \; && \
    find . -type f -not -perm 0644 -exec chmod 0644 {} \; && \
    find . ! -user www-data -exec chown www-data:www-data {} \; && \
    chmod +x bin/console

COPY config/php/php.ini /usr/local/etc/php/conf.d/
COPY config/apache/sites.conf /etc/apache2/sites-enabled/000-default.conf

RUN a2enmod rewrite

COPY config/cron/suitecrm /etc/cron.d/suitecrm
COPY scripts/entrypoint.sh /

ENTRYPOINT ["bash", "/entrypoint.sh"]

EXPOSE 80

USER www-data
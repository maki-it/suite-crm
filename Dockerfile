# https://docs.suitecrm.com/8.x/admin/compatibility-matrix/
FROM php:8.5-apache

# https://github.com/SuiteCRM/SuiteCRM-Core/releases
ARG SUITECRM_VERSION=8.9.3
ARG APPDIR=/opt/suitecrm
ARG WEBROOT=/var/www/html

RUN apt-get update && \
    apt-get upgrade -y && \
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

RUN mkdir -p ${APPDIR} && \
    curl -L -o ${APPDIR}/SuiteCRM-${SUITECRM_VERSION}.zip \
    https://github.com/SuiteCRM/SuiteCRM-Core/releases/download/v${SUITECRM_VERSION}/SuiteCRM-${SUITECRM_VERSION}.zip

COPY config/php/php.ini /usr/local/etc/php/conf.d/
COPY config/apache/sites.conf /etc/apache2/sites-enabled/000-default.conf

RUN a2enmod rewrite

COPY config/cron/suitecrm /etc/cron.d/suitecrm
COPY scripts/entrypoint.sh scripts/lib.sh /

ENTRYPOINT ["bash", "/entrypoint.sh"]

WORKDIR ${WEBROOT}
VOLUME ${WEBROOT}

ENV SUITECRM_VERSION=${SUITECRM_VERSION}
ENV WEBROOT=${WEBROOT}
ENV APPDIR=${APPDIR}

EXPOSE 80

LABEL suitecrm.version="${SUITECRM_VERSION}"
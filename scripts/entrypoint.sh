#!/usr/bin/env bash

APPDIR="/opt/suitecrm"
WEBROOT="/var/www/html"

set -e

is_installed() {
    if [ ! -f "${WEBROOT}/VERSION" ]; then
      return 1
    else
      return 0
    fi
}

is_latest_version() {
    local installed_version

    if [ -f "${WEBROOT}/VERSION" ]; then
        installed_version=$(cat "${WEBROOT}/VERSION")
        local app_version=${SUITECRM_VERSION}
        if [ "$installed_version" != "$app_version" ]; then
            echo "Version mismatch: Installed version is $installed_version, but expected $app_version."
            return 1
        else
            echo "Version check passed: Installed version is $installed_version."
            return 0
        fi
    else
        echo "VERSION file not found in ${WEBROOT}."
        return 1
    fi
}

set_permissions() {
    find . -type d -not -perm 2755 -exec chmod 2755 {} \; && \
    find . -type f -not -perm 0644 -exec chmod 0644 {} \; && \
    find . ! -user www-data -exec chown www-data:www-data {} \; && \
    chmod +x bin/console
}

if is_installed; then
    echo "SuiteCRM is already installed."
    if ! is_latest_version; then
        echo "Updating SuiteCRM to version ${SUITECRM_VERSION}..."
        mkdir -p ${WEBROOT}/tmp/package/upgrade/${SUITECRM_VERSION}
        ln -s ${APPDIR}/* ${WEBROOT}/tmp/package/upgrade/${SUITECRM_VERSION}
        ./bin/console suitecrm:app:upgrade -t ${SUITECRM_VERSION}
        set_permissions
        ./bin/console suitecrm:app:upgrade-finalize -t ${SUITECRM_VERSION}
        set_permissions
        rm -rf ${WEBROOT}/tmp/package/upgrade
        echo "SuiteCRM updated successfully."
    else
        echo "No update needed. SuiteCRM is up to date."
    fi
else
    echo "Installing SuiteCRM..."
    cp -R ${APPDIR}/* ${WEBROOT}/
    chown -R www-data:www-data ${WEBROOT}
    echo "SuiteCRM installed successfully."
fi

apache2-foreground
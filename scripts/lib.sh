#!/usr/bin/env bash

# This script contains common functions and variables for SuiteCRM installation and upgrade processes.

set -euo pipefail

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
    find $WEBROOT -type d -not -perm 2755 -exec chmod 2755 {} \; && \
    find $WEBROOT -type f -not -perm 0644 -exec chmod 0644 {} \; && \
    find $WEBROOT ! -user www-data -exec chown www-data:www-data {} \; && \
    chmod +x ${WEBROOT}/bin/console
}
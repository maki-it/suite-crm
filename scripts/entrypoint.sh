#!/usr/bin/env bash

set -euo pipefail

source /lib.sh

if is_installed; then
    echo "SuiteCRM is already installed."

    if ! is_latest_version; then
        echo "Upgrading SuiteCRM to version ${SUITECRM_VERSION}..."

        mkdir -p "${WEBROOT}/tmp/package/upgrade/${SUITECRM_VERSION}"

        mv "${APPDIR}/SuiteCRM-${SUITECRM_VERSION}.zip" "${WEBROOT}/tmp/package/upgrade/SuiteCRM-${SUITECRM_VERSION}.zip"

        ${WEBROOT}/bin/console suitecrm:app:upgrade --no-interaction --target-version="SuiteCRM-${SUITECRM_VERSION}"

        set_permissions

        ${WEBROOT}/bin/console suitecrm:app:upgrade-finalize --no-interaction --target-version="SuiteCRM-${SUITECRM_VERSION}"

        set_permissions

        rm -rf "${WEBROOT}/tmp/package/upgrade"

        echo "SuiteCRM updated successfully."
    else
        echo "No update needed. SuiteCRM is up to date."
    fi
else
    echo "Installing SuiteCRM v${SUITECRM_VERSION}..."

    unzip -q "${APPDIR}/SuiteCRM-${SUITECRM_VERSION}.zip" -d "${WEBROOT}"

    echo "Setting up permissions..."

    set_permissions

    echo "SuiteCRM installed successfully."
fi

apache2-foreground
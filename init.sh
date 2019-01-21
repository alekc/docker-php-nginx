#!/bin/sh
#define php extensions path
PHP_LIB_PATH=$(php-config --extension-dir)

if [ "${NEW_RELIC_ENABLED}" = true ]; then
    echo "Enabling new relic..."

    cat > ${PHP_CONF_D}/newrelic.ini <<- EOF
extension = "newrelic.so"
[newrelic]
newrelic.license = "${NEW_RELIC_KEY}"
newrelic.logfile = "/var/log/newrelic/php_agent.log"
newrelic.appname = "${NEW_RELIC_APP_NAME}"
newrelic.daemon.logfile = "/var/log/newrelic/newrelic-daemon.log"
EOF

    ln -s "${PHP_DBG_PATH}/newrelic.so" "${PHP_LIB_PATH}/newrelic.so"
    ln -s "${PHP_DBG_PATH}/newrelic.ini" "${PHP_CONF_D}/newrelic.ini"
    ln -s "${PHP_DBG_PATH}/s6/newrelic" /s6/

    if [ "${DEBUG_CONFIG_FILES}" = true ]; then
        cat "${PHP_CONF_D}/newrelic.ini"
    fi
else
    echo "Disabling new relic"
    rm -f "${PHP_LIB_PATH}/newrelic.so"
    rm -f "${PHP_CONF_D}/newrelic.ini"
    rm -f /s6/newrelic
fi

# add support for custom bash file
if [[ -x "/custom-init.sh" ]]
then
    /custom-init.sh
fi

# Launching s6
s6-svscan /s6
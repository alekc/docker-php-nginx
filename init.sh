#!/bin/sh
if [ "${NEW_RELIC_ENABLED}" = "true" ]; then
    echo "Enabling new relic"

    cat > ${PHP_CONF_D}/newrelic.ini <<- EOF
extension = "newrelic.so"
[newrelic]
newrelic.license = "${NEW_RELIC_KEY}"
newrelic.logfile = "/var/log/newrelic/php_agent.log"
newrelic.appname = "${NEW_RELIC_APP_NAME}"
newrelic.daemon.logfile = "/var/log/newrelic/newrelic-daemon.log"
EOF

    cp "${PHP_DBG_PATH}/newrelic.so" "${PHP_LIB_PATH}/newrelic.so"

    if [ "${DEBUG_CONFIG_FILES}" = true ]; then
        cat "${PHP_CONF_D}/newrelic.ini"
    fi
else
    echo "Disabling new relic"
    rm -f "${PHP_LIB_PATH}/newrelic.so"
    rm -f "${PHP_CONF_D}/newrelic.ini"
fi

# Launching s6
s6-svscan /s6
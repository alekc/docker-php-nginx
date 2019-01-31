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

    ln -sf "${PHP_DBG_PATH}/newrelic.so" "${PHP_LIB_PATH}/newrelic.so"
    #ln -s "${PHP_DBG_PATH}/newrelic.ini" "${PHP_CONF_D}/newrelic.ini"
    ln -sf "${PHP_DBG_PATH}/s6/newrelic" /s6/

    if [ "${DEBUG_CONFIG_FILES}" = true ]; then
        cat "${PHP_CONF_D}/newrelic.ini"
    fi
else
    echo "Disabling new relic"
    rm -f "${PHP_LIB_PATH}/newrelic.so"
    rm -f "${PHP_CONF_D}/newrelic.ini"
    rm -f /s6/newrelic
fi

if [ "${NUSPHERE_DBG_ENABLED}" = true ]; then
    echo "Enabling Nusphere debugger..."
    ln -sf "${PHP_DBG_PATH}/dbg-php.so" "${PHP_LIB_PATH}/dbg-php.so"
    cat > ${PHP_CONF_D}/nusphere-dbg.ini <<- EOF
zend_extension="${PHP_LIB_PATH}/dbg-php.so"
[debugger]
debugger.hosts_allow= ${NUSPHERE_DBG_ALLOWED_HOSTS}
debugger.hosts_deny=ALL
debugger.ports=${NUSPHERE_DBG_PORT}
EOF
else
    echo "Disabling Nusphere debugger..."
    rm ${PHP_CONF_D}/nusphere-dbg.ini
fi

# add support for custom bash file
if [[ -x "/custom-init.sh" ]]
then
    /custom-init.sh
fi

# Launching s6
s6-svscan /s6
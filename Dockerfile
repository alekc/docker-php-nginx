#################################
####
####   PHp nginx base
####   Thanks for inspiration: https://github.com/BretFisher/php-docker-good-defaults
####
#################################
ARG PHP_VERSION=7.2
ARG NUSPHERE_DEBUGGER_VERSION=9.0.11
ARG NUSPHERE_DEBUGGER_ARC=x86_64
ARG NEWRELIC_AGENT_VERSION=8.2.0.221

ARG PHP_DBG_PATH="/usr/local/php-dbg"
ARG NGINX_VERSION=1.15.7

FROM php:${PHP_VERSION}-fpm-alpine as base

# I am forced to disable this due to high pollution of ping logs in stdout.
RUN rm /usr/local/etc/php-fpm.d/docker.conf

#################################
####
####   PHP BUILDING STAGE
####
#################################
FROM base as php_builder
ARG PHP_DBG_PATH
ARG NEWRELIC_AGENT_VERSION

RUN apk --no-cache add curl

#NEW RELIC
RUN echo "Installing Newrelic"

RUN \
 curl -L https://download.newrelic.com/php_agent/archive/${NEWRELIC_AGENT_VERSION}/newrelic-php5-${NEWRELIC_AGENT_VERSION}-linux-musl.tar.gz | tar -C /tmp -zx && \
   NR_INSTALL_USE_CP_NOT_LN=1 NR_INSTALL_SILENT=1 /tmp/newrelic-php5-*/newrelic-install install



##XDEBUG
RUN echo "Xdebug installation"
RUN mkdir -p ${PHP_DBG_PATH}
RUN apk add --no-cache $PHPIZE_DEPS
RUN yes | pecl install xdebug
    #&& apk del $PHPIZE_DEPS



RUN find / -name 'xdebug.so' -type f -not -path ${PHP_DBG_PATH} -exec cp {} ${PHP_DBG_PATH}/ \;
RUN find / -name 'newrelic.so' -type f -not -path ${PHP_DBG_PATH} -exec cp {} ${PHP_DBG_PATH}/ \;


#RUN ls -l ${PHP_DBG_PATH}

#################################
####
####   NGINX BUILDING STAGE
####
#################################
FROM base as nginx_base_build
ARG NGINX_VERSION

#Taken from https://raw.githubusercontent.com/nginxinc/docker-nginx/master/mainline/alpine/Dockerfile
RUN GPG_KEYS=B0F4253373F8F6F510D42178520A9993A1C052F8 \
        && CONFIG="\
            --prefix=/etc/nginx \
            --sbin-path=/usr/sbin/nginx \
            --modules-path=/usr/lib/nginx/modules \
            --conf-path=/etc/nginx/nginx.conf \
            --error-log-path=/var/log/nginx/error.log \
            --http-log-path=/var/log/nginx/access.log \
            --pid-path=/var/run/nginx.pid \
            --lock-path=/var/run/nginx.lock \
            --http-client-body-temp-path=/var/cache/nginx/client_temp \
            --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
            --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
            --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
            --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
            --user=nginx \
            --group=nginx \
            --with-http_ssl_module \
            --with-http_realip_module \
            --with-http_addition_module \
            --with-http_sub_module \
            --with-http_dav_module \
            --with-http_flv_module \
            --with-http_mp4_module \
            --with-http_gunzip_module \
            --with-http_gzip_static_module \
            --with-http_random_index_module \
            --with-http_secure_link_module \
            --with-http_stub_status_module \
            --with-http_auth_request_module \
            --with-http_xslt_module=dynamic \
            --with-http_image_filter_module=dynamic \
            --with-http_geoip_module=dynamic \
            --with-threads \
            --with-stream \
            --with-stream_ssl_module \
            --with-stream_ssl_preread_module \
            --with-stream_realip_module \
            --with-stream_geoip_module=dynamic \
            --with-http_slice_module \
            --with-mail \
            --with-mail_ssl_module \
            --with-compat \
            --with-file-aio \
            --with-http_v2_module \
        " \
        && addgroup -S nginx \
        && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
        && apk add --no-cache --virtual .build-deps \
            gcc \
            libc-dev \
            make \
            openssl-dev \
            pcre-dev \
            zlib-dev \
            linux-headers \
            curl \
            gnupg1 \
            libxslt-dev \
            gd-dev \
            geoip-dev \
        && curl -fSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
        && curl -fSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc  -o nginx.tar.gz.asc \
        && export GNUPGHOME="$(mktemp -d)" \
        && found=''; \
        for server in \
            ha.pool.sks-keyservers.net \
            hkp://keyserver.ubuntu.com:80 \
            hkp://p80.pool.sks-keyservers.net:80 \
            pgp.mit.edu \
        ; do \
            echo "Fetching GPG key $GPG_KEYS from $server"; \
            gpg --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$GPG_KEYS" && found=yes && break; \
        done; \
        test -z "$found" && echo >&2 "error: failed to fetch GPG key $GPG_KEYS" && exit 1; \
        gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz \
        && rm -rf "$GNUPGHOME" nginx.tar.gz.asc \
        && mkdir -p /usr/src \
        && tar -zxC /usr/src -f nginx.tar.gz \
        && rm nginx.tar.gz \
        && cd /usr/src/nginx-$NGINX_VERSION \
        && ./configure $CONFIG --with-debug \
        && make -j$(getconf _NPROCESSORS_ONLN) \
        && mv objs/nginx objs/nginx-debug \
        && mv objs/ngx_http_xslt_filter_module.so objs/ngx_http_xslt_filter_module-debug.so \
        && mv objs/ngx_http_image_filter_module.so objs/ngx_http_image_filter_module-debug.so \
        && mv objs/ngx_http_geoip_module.so objs/ngx_http_geoip_module-debug.so \
        && mv objs/ngx_stream_geoip_module.so objs/ngx_stream_geoip_module-debug.so \
        && ./configure $CONFIG \
        && make -j$(getconf _NPROCESSORS_ONLN) \
        && make install \
        && rm -rf /etc/nginx/html/ \
        && mkdir /etc/nginx/conf.d/ \
        && mkdir -p /usr/share/nginx/html/ \
        && install -m644 html/index.html /usr/share/nginx/html/ \
        && install -m644 html/50x.html /usr/share/nginx/html/ \
        && install -m755 objs/nginx-debug /usr/sbin/nginx-debug \
        && install -m755 objs/ngx_http_xslt_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_xslt_filter_module-debug.so \
        && install -m755 objs/ngx_http_image_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_image_filter_module-debug.so \
        && install -m755 objs/ngx_http_geoip_module-debug.so /usr/lib/nginx/modules/ngx_http_geoip_module-debug.so \
        && install -m755 objs/ngx_stream_geoip_module-debug.so /usr/lib/nginx/modules/ngx_stream_geoip_module-debug.so \
        && ln -s ../../usr/lib/nginx/modules /etc/nginx/modules \
        && strip /usr/sbin/nginx* \
        && strip /usr/lib/nginx/modules/*.so \
        && rm -rf /usr/src/nginx-$NGINX_VERSION \
        \
        # Bring in gettext so we can get `envsubst`, then throw
        # the rest away. To do this, we need to install `gettext`
        # then move `envsubst` out of the way so `gettext` can
        # be deleted completely, then move `envsubst` back.
        && apk add --no-cache --virtual .gettext gettext \
        && mv /usr/bin/envsubst /tmp/ \
        \
        && runDeps="$( \
            scanelf --needed --nobanner --format '%n#p' /usr/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst \
                | tr ',' '\n' \
                | sort -u \
                | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
        )" \
        && apk add --no-cache --virtual .nginx-rundeps $runDeps \
        && apk del .build-deps \
        && apk del .gettext \
        && mv /tmp/envsubst /usr/local/bin/ \
        \
        # Bring in tzdata so users could set the timezones through the environment
        # variables
        && apk add --no-cache tzdata \
        \
        # forward request and error logs to docker log collector
        && ln -sf /dev/stdout /var/log/nginx/access.log \
        && ln -sf /dev/stderr /var/log/nginx/error.log

#################################
####
####   FINAL ASSEMBLY PAGE
####
#################################
FROM nginx_base_build as final

ARG NUSPHERE_DEBUGGER_VERSION
ARG NUSPHERE_DEBUGGER_ARC
ARG PHP_DBG_PATH

EXPOSE 80

RUN apk --no-cache add curl s6

#Copy over compiled php dll
COPY --from=php_builder ${PHP_DBG_PATH}/xdebug.so ${PHP_DBG_PATH}/xdebug.so
COPY --from=php_builder ${PHP_DBG_PATH}/newrelic.so ${PHP_DBG_PATH}/newrelic.so
COPY --from=php_builder /usr/bin/newrelic-daemon /usr/bin/newrelic-daemon
COPY --from=php_builder /lib/ld-musl-x86_64.so.1 /lib/ld-musl-x86_64.so.1
RUN mkdir -p /var/log/newrelic

#ENVIRONMENT
ENV PHP_DBG_PATH ${PHP_DBG_PATH}
ENV PHP_CONF_D /usr/local/etc/php/conf.d

#newrelic
ENV NEW_RELIC_ENABLED false
ENV NEW_RELIC_KEY  "xxxxx"
ENV NEW_RELIC_APP_NAME "MyAPP"

#php-fpm
ENV FPM_ERROR_LOG="/var/log/php-fpm-error.log"
ENV FPM_PING_PATH="/fpm-ping"
ENV FPM_PING_RESPONSE="/fpm-ping"
ENV FPM_PM_STATUS_PATH="/fpm-status"
ENV FPM_PM=ondemand
ENV FPM_PM_MAX_CHILDREN=30
ENV FPM_PM_START_SERVERS=3
ENV FPM_PM_MIN_SPARE_SERVERS=2
ENV FPM_PM_MAX_SPARE_SERVERS=4
ENV FPM_PM_MAX_REQUESTS=500
ENV FPM_PROCESS_MAX_IDLE_TIMEOUT=10s
ENV FPM_REQUEST_SLOWLOG_TIMEOUT=30s
ENV FPM_SLOWLOG=/var/log/php-fpm-slow.log

#PHP INI
ENV PHP_INI_DISPLAY_ERRORS=off
ENV PHP_INI_DISPLAY_STARTUP_ERRORS=off
ENV PHP_INI_ERROR_REPORTING="E_ALL & ~E_DEPRECATED & ~E_STRICT"
ENV PHP_INI_LOG_ERRORS=on
ENV PHP_INI_ERROR_LOG=/var/log/php-fpm.log
ENV PHP_INI_MAX_EXECUTION_TIME=30
ENV PHP_INI_MEMORY_LIMIT=128
ENV PHP_INI_UPLOAD_MAX_FILESIZE=2M
ENV PHP_INI_POST_MAX_SIZE=8M

#nusphere debugger
ENV NUSPHERE_DBG_ENABLED false
ENV NUSPHERE_DBG_ALLOWED_HOSTS "172.18.0.0/24 localhost 127.0.0.1 host.docker.internal .localhost"

#s6 config
COPY s6 /s6
RUN chmod -R +x /s6
RUN mkdir ${PHP_DBG_PATH}/s6/
RUN mv /s6/newrelic ${PHP_DBG_PATH}/s6/
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS 2 #send a termination signal to whole branch

#Prepare init
COPY init.sh /
RUN chmod +x /init.sh

#Prepare nginx config
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/nginx.vh.default.conf /etc/nginx/conf.d/default.conf
RUN mkdir -p /var/www/default
COPY nginx/index.php /var/www/default/

HEALTHCHECK --interval=1s --timeout=3s \
  CMD curl --fail http://localhost${FPM_PING_PATH} || exit 1

COPY .profile /root/.ashrc
ENV ENV="/root/.ashrc"
ENTRYPOINT ["/init.sh"]
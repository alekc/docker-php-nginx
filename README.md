# Docker Php Nginx container
---

## Description
---
Coming soon

## Configuration Variables

##### New Relic

| Name               | Default value | Description |
|---|---|---|
| NEW_RELIC_ENABLED  | false         |             |
| NEW_RELIC_KEY      | xxxxx         |             |
| NEW_RELIC_APP_NAME | MyAPP         |             |

##### Fpm configuration

| Name                         | Default value              | Description |
|---                           | ---                        |          ---|
| FPM_ERROR_LOG                | /var/log/php-fpm-error.log |             |
| FPM_PING_PATH                | /fpm-ping                  |             |
| FPM_PING_RESPONSE            | /fpm-ping                  |             |
| FPM_PM_STATUS_PATH           | /fpm-status                |             |
| FPM_PM                       | ondemand                   |             |
| FPM_PM_MAX_CHILDREN          | 30                         |             |
| FPM_PM_START_SERVERS         | 3                          |             |
| FPM_PM_MIN_SPARE_SERVERS     | 2                          |             |
| FPM_PM_MAX_SPARE_SERVERS     | 4                          |             |
| FPM_PM_MAX_REQUESTS          | 500                        |             |
| FPM_PROCESS_MAX_IDLE_TIMEOUT | 10s                        |             |
| FPM_REQUEST_SLOWLOG_TIMEOUT  | 30s                        |             |
| FPM_SLOWLOG                  | /var/log/php-fpm-slow.log  |             |

##### PHP settings

| Name                           | Default value                     | Description |
|----                            | ---                               |          ---|
| PHP_INI_DISPLAY_ERRORS         | off                               |             |
| PHP_INI_DISPLAY_STARTUP_ERRORS | off                               |             |
| PHP_INI_ERROR_REPORTING        | E_ALL & ~E_DEPRECATED & ~E_STRICT |             |
| PHP_INI_LOG_ERRORS             | on                                |             |
| PHP_INI_ERROR_LOG              | /var/log/php-fpm.log              |             |
| PHP_INI_MAX_EXECUTION_TIME     | 30                                |             |
| PHP_INI_MEMORY_LIMIT           | 128M                              |             |
| PHP_INI_UPLOAD_MAX_FILESIZE    | 2M                                |             |
| PHP_INI_POST_MAX_SIZE          | 8M                                |             |
| PHP_INI_DATE_TIMEZONE          | Europe/London                     |             |
| PHP_INI_GC_MAXLIFETIME         | 1440                              |             |
| PHP_INI_SESSION_SAVE_HANDLER   | files                             |             |
| PHP_INI_SESSION_SAVE_PATH      |                                   |             |

##### Nusphere Debugger
| Name                       | Default value                                 | Description |
|-----                       | ---                                           |          ---|
| NUSPHERE_DBG_ENABLED       | false                                         |             |
| NUSPHERE_DBG_PORT          | 7869                                          |             |
| NUSPHERE_DBG_ALLOWED_HOSTS | 172.18.0.0/24 localhost 127.0.0.1 host.docker |             |
|                            |                                               |             |

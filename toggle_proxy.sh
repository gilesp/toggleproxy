#!bin/sh

IF=$1
STATUS=$2

PROXY_DOMAIN="office.blackpepper.co.uk"
CONF_LOCATION="/etc/systemd/system/docker.service.d"
ENABLED_FILE="$CONF_LOCATION/http_proxy.conf"
DISABLED_FILE="$CONF_LOCATION/http_proxy.disabled"

restart_docker() {
    # systemctl daemon-reload
    systemctl restart docker
}

proxy_enabled() {
    if [ -f "$ENABLED_FILE" ]; then
        return 0
    else
        return 1
    fi
}

set_proxy() {
    if [ "$1" = "enable" ]; then
        if ! proxy_enabled; then
            logger "$0 - enabling proxy"
            mv $DISABLED_FILE $ENABLED_FILE
            restart_docker
        fi
    else
        if proxy_enabled; then
            logger "$0 - disabling proxy"
            mv $ENABLED_FILE $DISABLED_FILE
            restart_docker
        fi
    fi
}

enable_proxy() {
    set_proxy "enable"
}

disable_proxy() {
    set_proxy "disable"
}

# See
# https://developer.gnome.org/NetworkManager/unstable/NetworkManager.html
# for details of available environment variables
#logger "$0 - Domain: $IP4_DOMAINS Status: $STATUS"
if [ "$IP4_DOMAINS" = "$PROXY_DOMAIN" ]; then
    if [ "$STATUS" = "up" ]; then
        enable_proxy
    fi
else
    disable_proxy
fi

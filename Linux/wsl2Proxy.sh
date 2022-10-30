#!/bin/bash

: '
# Add this two line to your shell config then getting advanced exp...REMEMBER TO RELOAD CONFIG!
alias proxy="source /path/to/your/proxy.sh"
. /path/to/your/proxy.sh set
'

HOST_IP=$(cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }')
WSL_IP=$(hostname -I | awk '{print $1}')
PROXY_PORT="10800"
# PROXY_ADDRESS="socks://${HOST_IP}:${PROXY_PORT}"
PROXY_ADDRESS="socks://127.0.0.1:${PROXY_PORT}"

set_proxy(){
    export {http,https}_proxy="${PROXY_ADDRESS}"
    export {HTTP,HTTPS}_PROXY="${PROXY_ADDRESS}"
    git config --global http.proxy "${PROXY_ADDRESS}"
    git config --global https.proxy "${PROXY_ADDRESS}"
}

unset_proxy(){
    unset {http,https}_proxy
    unset {HTTP,HTTPS}_PROXY
    git config --global --unset http.proxy
    git config --global --unset https.proxy
}

test_setting(){
    echo "Host ip:" ${HOST_IP}
    echo "WSL ip:" ${WSL_IP}
    echo "http proxy:" $http_proxy
}

if [ "$1" = "set" ]
then
    set_proxy

elif [ "$1" = "unset" ]
then
    unset_proxy

elif [ "$1" = "test" ]
then
    test_setting
else
    echo "Unsupported arguments."
fi
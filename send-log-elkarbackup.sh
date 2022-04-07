#!/bin/bash
#
# Script que envía al slack de CATEDU al canal #servidores_info el log de tiempos de elkarbackup

###############################
# functions
###############################
genera_mensaje(){
    cat <<EOF
        {"text":"$detalle"}
EOF
}
###############################
# vars
###############################

source /home/debian/scripts/env.sh

###############################
# main
###############################
detalle=$(cat $LOG_FILE)
# echo "detalle: $detalle"

curl -X POST -H 'Content-type: application/json'  --data "$(genera_mensaje)" "${URL_SLACK_INFO}"
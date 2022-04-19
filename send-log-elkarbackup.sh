#!/bin/bash
#
# Script que envía al slack de CATEDU al canal #servidores_info el log de tiempos de elkarbackup

###############################
# functions
###############################
genera_mensaje_maquina(){
    cat <<EOF
        {"text":"[$ENTORNO]"}
EOF
}
genera_mensaje(){
    cat <<EOF
        {"text":"$detalle"}
EOF
}
###############################
# vars
###############################

source /home/debian/scripts-monitorizacion-servers/env.sh

###############################
# main
###############################
detalle=$(cat $LOG_FILE | tail -n40)
# echo "detalle: $detalle"
curl -X POST -H 'Content-type: application/json'  --data "$(genera_mensaje_maquina)" "${URL_SLACK_INFO}"
curl -X POST -H 'Content-type: application/json'  --data "$(genera_mensaje)" "${URL_SLACK_INFO}"
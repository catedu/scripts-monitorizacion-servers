#!/bin/bash
# Script que comprueba si hay intentos de acceso fallidos
# y de ser así manda mensaje al slack de CATEDU al canal #servidores_alertas mencionando a $NOTIFICAR_A
# lo hace a través de examinar el contenido de /var/log/auth.log
# TODO: En elaboración

###############################
# functions
###############################
genera_mensaje(){
    cat <<EOF
        {"text":"[FP-Backup] Fallan $fallan discos del RAID. Deberían ser 0. $NOTIFICAR_A "}
EOF
}
###############################
# vars
###############################

source /home/debian/scripts/env.sh

###############################
# main
###############################

month_short_name=$( date -u +"%b" )
echo "month_short_name: $month_short_name"
day=$( date -u +"%d" )
echo "day: $day"

if [ $day -lt 10 ]

# logDeHoy=$( cat /var/log/auth.log | grep -e "$date" ) failure
# echo "logDeHoy: $logDeHoy"
#!/bin/bash
# Script que comprueba si hay intentos de acceso fallidos
# y de ser así manda mensaje al slack de CATEDU al canal #servidores_alertas mencionando a $NOTIFICAR_A
# lo hace a través de examinar el contenido de /var/log/auth.log

###############################
# functions
###############################
genera_mensaje(){
    cat <<EOF
        {"text":"[$ENTORNO] ATENCIÓN: Hoy hay intentos de acceso falidos al servidor. $NOTIFICAR_A . Log: $logDeHoy .  "}
EOF
}
###############################
# vars
###############################

source /home/debian/scripts-monitorizacion-servers/env.sh

###############################
# main
###############################

month_short_name=$( date -u +"%b" )
echo "month_short_name: $month_short_name"
day=$( date -u +"%d" )
echo "day: $day"

if [ $day -lt 10 ];
then
    day=${day#?}
fi
echo "day: $day"

logDeHoy=$( cat /var/log/auth.log | grep -e "$month_short_name  $day" | grep failure )

if [ ! -z "$logDeHoy" ];
then
    # echo $logDeHoy
    curl -X POST -H 'Content-type: application/json'  --data "$(genera_mensaje)" "${URL_SLACK_ALERTAS}"
fi
#!/bin/bash
# Script que comprueba si mas de un determinado porcentaje de la partición para
# copias de seguridad está en uso y de ser así manda un mensaje al slack de CATEDU
# al canal #servidores_alertas notificándolo a $NOTIFICAR_A

###############################
# functions
###############################
genera_mensaje(){
    cat <<EOF
        {"text":"[$ENTORNO] El $porcentaje de $montado está en uso. Queda libre $absolutoLibre de $absolutoTotal. $NOTIFICAR_A"}
EOF
}
###############################
# vars
###############################

source /home/debian/scripts-monitorizacion-servers/env.sh

###############################
# main
###############################

disco=$(df -h | grep backupall)

porcentaje=$(echo $disco | cut -d" " -f5)

porcentajeSinSimbolo=${porcentaje%?}

absolutoLibre=$(echo $disco | cut -d" " -f4)

absolutoTotal=$(echo $disco | cut -d" " -f2)

montado=$(echo $disco | cut -d" " -f1)

# Si mas del 80% está en uso me mando chivato
if [ $porcentajeSinSimbolo -gt 79 ]
then
    ! grep $(date +%Y%m%d) disk-use-monitoring.log >/dev/null && curl -X POST -H 'Content-type: application/json' --data "$(genera_mensaje)" "${URL_SLACK_ALERTAS}"

    date +%Y%m%d > disk-use-monitoring.log

fi
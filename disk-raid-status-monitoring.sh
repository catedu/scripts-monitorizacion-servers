#!/bin/bash
# Script que comprueba si los 4 discos involucrados en el RAID de este equipo están ativos. De no ser así manda un 
# mensaje al slack de CATEDU al canal #servidores_alertas notificándolo a $NOTIFICAR_A

###############################
# functions
###############################
genera_mensaje(){
    cat <<EOF
        {"text":"[$ENTORNO] Solo hay $activos discos activos en el RAID. Deberían ser 4. $NOTIFICAR_A"}
EOF
}
###############################
# vars
###############################

source /home/debian/scripts-monitorizacion-servers/env.sh

###############################
# main
###############################

nodeExporter=$(curl http://localhost:9100/metrics | grep node_md_disk | grep active | cut -d" " -f2 | tail -n1  )
activos=$(echo $nodeExporter | tail -n1 )
echo $activos

# Si hay una cantidad distinta de 4 discos
if [ $activos -ne 4 ]
then
    curl -X POST \
    -H 'Content-type: application/json' \
    --data "$(genera_mensaje)" \
    "${URL_SLACK_ALERTAS}"  
fi
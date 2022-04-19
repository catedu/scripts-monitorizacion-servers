#!/bin/bash
# Script que comprueba si alguno de los discos del RAID ha fallado
# y de ser así manda mensaje al slack de CATEDU al canal #servidores_alertas mencionando a $NOTIFICAR_A
# TODO prescindir de node exporter y usar "sudo mdadm -D /dev/md127" o "cat /proc/mdstat"
# TODO mas info en https://unix.stackexchange.com/questions/28636/how-to-check-mdadm-raids-while-running

###############################
# functions
###############################
genera_mensaje(){
    cat <<EOF
        {"text":"[$ENTORNO] Fallan $fallan discos del RAID. Deberían ser 0. $NOTIFICAR_A "}
EOF
}
###############################
# vars
###############################

source /home/debian/scripts-monitorizacion-servers/env.sh

###############################
# main
###############################
nodeExporter=$(curl http://localhost:9100/metrics | grep node_md_disk | grep failed | cut -d" " -f2 | tail -n1  )
fallan=$(echo $nodeExporter | tail -n1 )
echo $fallan

# Si fallan mas de 0 discos aviso
if [ $fallan -gt 0 ]
then
    curl -X POST \
    -H 'Content-type: application/json' \
    --data "$(genera_mensaje)" \
    "${URL_SLACK_ALERTAS}" 
fi
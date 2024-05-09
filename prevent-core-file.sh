#!/bin/bash
# Script que comprueba si existe el fichero core que genera moodle y nos impide las copias ed seguridad
# y de ser así manda mensaje al slack de CATEDU al canal #servidores_alertas mencionando a $NOTIFICAR_A

# TODO: Hacer que borre el fichero una vez localizado

###############################
# functions
###############################
genera_mensaje(){
    cat <<EOF
        {"text":"[$ENTORNO] ATENCIÓN: Se ha generado un fichero core. $NOTIFICAR_A . Ubicacion: $resultado .  "}
EOF
}
###############################
# vars
###############################

source /home/debian/scripts-monitorizacion-servers/env.sh

###############################
# main
###############################
resultado=$(find "/var/moodle-docker-deploy/*/moodle-code/admin/cli" -type f -name "core" )
# echo $resultado
#
if  [ -n "$resultado" ]; then
    curl -X POST -H 'Content-type: application/json'  --data "$(genera_mensaje)" "${URL_SLACK_ALERTAS}"
else
    echo "NO he encontrado el fichero"
fi

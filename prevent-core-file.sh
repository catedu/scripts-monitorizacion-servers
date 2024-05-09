#!/bin/bash
# Script que comprueba si hay intentos de acceso fallidos
# y de ser así manda mensaje al slack de CATEDU al canal #servidores_alertas mencionando a $NOTIFICAR_A
# lo hace a través de examinar el contenido de /var/log/auth.log
# TODO: Una vez verifique que funciona en FP hacer que busque en cualquier dura con ese patrón

###############################
# functions
###############################
genera_mensaje(){
    cat <<EOF
        {"text":"[$ENTORNO] ATENCIÓN: Se ha generado un fichero core. $NOTIFICAR_A . Ubicacion: $ruta .  "}
EOF
}
###############################
# vars
###############################

source /home/debian/scripts-monitorizacion-servers/env.sh

###############################
# main
###############################
resultado=$(find "/var/moodle-docker-deploy/www.adistanciafparagon.es/moodle-code/admin/cli" -type f -name "core" )
ruta="";
# echo $resultado
#
if  [ -n "$resultado" ]; then
    echo "He encontrado el fichero"
    ruta="/var/moodle-docker-deploy/www.adistanciafparagon.es/moodle-code/admin/cli/"
    curl -X POST -H 'Content-type: application/json'  --data "$(genera_mensaje)" "${URL_SLACK_ALERTAS}"
else
    echo "NO he encontrado el fichero"
fi

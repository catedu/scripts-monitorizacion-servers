#!/bin/bash
#
# Script que comprueba la realización de las copias de seguridad y los tiempos que han llevado. También saca los detalles de cada copia.
# Manda mensaje al slack de CATEDU al canal #servidores_info
# TODO La info que devuelve la extrae de BBDD ¿deberíamos comprobar también en disco que está ocurriendo?

###############################
# functions
###############################
# Lo que va entre * está en negritas
genera_mensaje_maestro(){
    cat <<EOF
        {"text":"*[$ENTORNO] El $date la copia de $cliente - $trabajo ($link) llevó $tiempo.*"}
EOF
}

genera_mensaje_detalle(){
    cat <<EOF
        {"text":"$detalle"}
EOF
}

genera_mensaje_maestro_errores(){
    cat <<EOF
        {"text":"*[$ENTORNO] $date : $value* $NOTIFICAR_A "}
EOF
}
###############################
# vars
###############################

source /home/debian/scripts-monitorizacion-servers/env.sh

###############################
# main
###############################
date=$( date -u +"%Y-%m-%d" )

# Recorro las tareas y por cada una muestro cuanto tiempo ha pasado entre sus pre y post scripts para ver su duración

for link in $( mysql -u ${USERDB} -p${PASSDB} -N -e "select distinct link from elkarbackup.LogRecord where datetime like '$date%' and link like '%job%' and link is not null and level > 100" )
do
    # echo "link: $link"

    # Descompongo el link para obtener el client y el job
    IFS='/' array=($link)
    # echo "client_id: ${array[2]}"
    # echo "job_id: ${array[4]}"

    # Compruebo si el job está activo antes de hacer nada. Si es un job inactivo lo ignoramos
    activo=$( mysql -u ${USERDB} -p${PASSDB} -N -e "select isActive from elkarbackup.Job where client_id = '${array[2]}' and id = '${array[4]}'" )
    if [[ "$activo" = "0" ]]; then
        continue
    fi
    
    # Obtengo el tiempo que lleva
    tiempo=$( mysql -u ${USERDB} -p${PASSDB} -N -e "select TIMEDIFF(post.dateTime, pre.dateTime) from (select dateTime from elkarbackup.LogRecord where link = '$link' and dateTime like '$date%' and source = 'RunPreJobScriptsCommand'  ) pre, (select dateTime from elkarbackup.LogRecord where link = '$link' and dateTime like '$date%' and source = 'RunPostJobScriptsCommand'  ) post" )
    # echo "tiempo: $tiempo"

    #Obtengo el nombre del cliente
    cliente=$( mysql -u ${USERDB} -p${PASSDB} -N -e "select name from elkarbackup.Client where id = '${array[2]}' " )
    # echo "cliente: $cliente"

    # Obtengo el nombre del job
    trabajo=$( mysql -u ${USERDB} -p${PASSDB} -N -e "select name from elkarbackup.Job where client_id = '${array[2]}' and id = '${array[4]}'" )
    # echo "trabajo: $trabajo"

    # Envío el mensaje a SLACK
    curl -X POST -H 'Content-type: application/json'  --data "$(genera_mensaje_maestro)" "${URL_SLACK_INFO}"

    # Llevo los tiempos a un fichero de log para detectar fácilmente los tiempos de backup de cada job
    echo "[FP-Backup] El $date la copia de $cliente - $trabajo ($link) llevó $tiempo." | sudo tee -a "${LOG_FILE}"

    #Obtengo los detalles de la copia
    for detalle in $( mysql -u ${USERDB} -p${PASSDB} -N -e "select REPLACE(REPLACE(message,'\"','\''),'/',' per ') from elkarbackup.LogRecord where datetime like '$date%' and link = '$link' and level > 100 and source = 'RunJobCommand' AND message like '%Command%' " )
    do
        # echo "detalle: $detalle"
        curl -X POST -H 'Content-type: application/json'  --data "$(genera_mensaje_detalle)" "${URL_SLACK_INFO}"
    done

done

# Recorro los registros del día de hoy cuyo nivel corresponde a warnings o errors
mysql -u ${USERDB} -p${PASSDB} -N -e "select link, message from elkarbackup.LogRecord where datetime like '$date%' and link like '%job%' and link is not null and level > 200" | while read -r id value;
do
    curl -X POST -H 'Content-type: application/json'  --data "$(genera_mensaje_maestro_errores)" "${URL_SLACK_ALERTAS}"
done
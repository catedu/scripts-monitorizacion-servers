# scripts-monitorizacion-servers
Scripts para la monitorización de los diferentes servidores

## Configuración
A partir del fichero `env-sample.sh` crear un fichero `env.sh`
Configurar en crontab (o vía servicios) la ejecución de los distintos scripts según se requiera. Se comparte un fichero `crontab-sample` a modo de sugerencia

## Requerimientos
Algún script requiere tener instalado node-export como servicio. Se espera cambiar la necesidad de este servicio por otras alternativas. 

## Monitorización de discos
- `disk-raid-fail-monitoring.sh`
- `disk-raid-status-monitoring.sh`
- `disk-use-monitoring.sh`

## Monitorización de logs del sistema
- `ssh_access-failure-monitoring.sh`

## Monitorización de copias de seguridad
- `log-elkarbackup-monitoring.sh`
- `send-log-elkarbackup.sh`
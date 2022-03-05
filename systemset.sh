#!/bin/bash

#mit diesem Script wird erreicht, dass nach einer SystemNeuinstallation
#grundlegende Einstellungen vorgenommen werden
#-----------------------------------------------------------------------
#Variablenbefuellung
datum=$(date +'%Y-%m-%d')
thisweek=$(date +'%U')
lastweek=$(date --date '2 week ago' '+%U')
zeit=$(date +'%H-%M-%S')
path_log=/home/docker/logs/KW_
#-----------------------------------------------------------------------
#Ordner mit aktuellem Datum fuer Log anlegen
path_log=$path_log$thisweek
mkdir -p $path_log
#-----------------------------------------------------------------------
#Umleiten aller Fehlermeldungen an Log-Datei
exec > >(tee $path_log/system-setup_$datum'_'$zeit.log) 2>&1
#-----------------------------------------------------------------------
#OrdnerStruktur anlegen
mkdir -pv /mnt/hdd1 /mnt/hdd2 /mnt/usb1 /mnt/usb2 /mnt/webdav /mnt/webdavcache

# Reporsitory für Webmin installieren
echo -e "\n\n#Zusatzeintrag für Webmin\ndeb http://download.webmin.com/download/repository sarge contrib" \
          	>> /etc/apt/sources.list.d/webmin.list
wget http://www.webmin.com/jcameron-key.asc && apt-key add jcameron-key.asc
#Programme installieren
apt-get update -y && apt-get dist-upgrade -y
apt-get -y install webmin davfs2

#Docker mit apt intallieren
docker network create extern

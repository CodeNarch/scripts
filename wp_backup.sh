#!/bin/bash
 
################################################################
##
##   MySQL Database and Wordpress Backup Script 
##   Written By: Harshana Weerasinghe
##   Last Update: Jun 23, 2019
##
################################################################
 
export PATH=/bin:/usr/bin:/usr/local/bin
TODAY=`date +"%d%b%Y"`
 
################################################################
################## Update below values  ########################
 
DB_BACKUP_PATH='/backup/dbbackup'
MYSQL_HOST='localhost'
MYSQL_PORT='3306'
MYSQL_USER='USER'
MYSQL_PASSWORD='PASSWORD'
DATABASE_NAME='DB'
BACKUP_RETAIN_DAYS=30   ## Number of days to keep local backup copy
SITE_BACKUP_PATH='/backup/sitebackup'
SITE_PATH='/var/www/html/'

#################################################################
 
mkdir -p ${DB_BACKUP_PATH}/${TODAY}
echo "Backup started for database - ${DATABASE_NAME}"
 
 
mysqldump -h ${MYSQL_HOST} \
   -P ${MYSQL_PORT} \
   -u ${MYSQL_USER} \
   -p${MYSQL_PASSWORD} \
   ${DATABASE_NAME} | gzip > ${DB_BACKUP_PATH}/${TODAY}/${DATABASE_NAME}-${TODAY}.sql.gz
 
if [ $? -eq 0 ]; then
  echo "Database backup successfully completed"
else
  echo "Error found during backup"
  exit 1
fi
 
##### Wordpress Backup

mkdir -p ${SITE_BACKUP_PATH}/${TODAY}

tar -czvf ${SITE_BACKUP_PATH}/${TODAY}/files-${TODAY}.tar.gz ${SITE_PATH}


echo "Wordpress site backup successfully completed"


##### Remove backups older than {BACKUP_RETAIN_DAYS} days  #####
 
DBDELDATE=`date +"%d%b%Y" --date="${BACKUP_RETAIN_DAYS} days ago"`
 
if [ ! -z ${DB_BACKUP_PATH} ]; then
      cd ${DB_BACKUP_PATH}
      if [ ! -z ${DBDELDATE} ] && [ -d ${DBDELDATE} ]; then
            rm -rf ${DBDELDATE}
      fi
fi
 
if [ ! -z ${SITE_BACKUP_PATH} ]; then
      cd ${SITE_BACKUP_PATH}
      if [ ! -z ${DBDELDATE} ] && [ -d ${DBDELDATE} ]; then
            rm -rf ${DBDELDATE}
      fi
fi 

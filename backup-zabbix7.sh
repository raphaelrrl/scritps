#!/bin/bash
#backup frontend,alert scripts, external scripts e databases mysql zabbix
# para importar o dump do banco de dado, executar este comando mysqldump -u username -p database_name > data-dump.sql
#set variaveis
user="zabbix"
password="password"
host="localhost"
db_name="zabbix"

# Other options backup_path="/home/backup"
backup_path="/opt/backup"
date=$(date +"%d-%b-%Y")

# Aplicar permissões
umask 177
# Create directory backup
mkdir $backup_path
mkdir $backup_path/backup-$date
mkdir $backup_path/backup-$date/frontend
mkdir $backup_path/backup-$date/alertscripts
mkdir $backup_path/backup-$date/externalscripts
mkdir $backup_path/backup-$date/database
mkdir $backup_path/backup-$date/fileconf
mkdir $backup_path/backup-$date/fileconf/mysql

# Dump database into SQL file
mysqldump --user=$user --password=$password --host=$host $db_name --single-transaction --skip-lock-tables > $backup_path/backup-$date/database/$db_name-$date.sql.bkp

# Delete files older than 30 days
find $backup_path/backup-$date/database/* -mtime +30 -exec rm {} \;

# Backup Frontend
cp -R /usr/share/zabbix/* $backup_path/backup-$date/frontend

# Alert Scripts
cp -R /usr/lib/zabbix/alertscripts/* $backup_path/backup-$date/alertscripts

# External Scripts
cp -R /usr/lib/zabbix/externalscripts/* $backup_path/backup-$date/externalscripts

# Files Cofiguration
cp -R /etc/zabbix/* $backup_path/backup-$date/fileconf

# File Cofiguration my.cnf
cp -R /etc/mysql/mariadb.conf.d/50-server.cnf $backup_path/backup-$date/fileconf/mysql

# File Cofiguration my.cnf
cp -R /etc/mysql/* $backup_path/backup-$date/fileconf/mysql

# Add File to .tar
tar -cvf $backup_path/backup-$date.tar

# Add File to .tar.gz
gzip $backup_path/backup-$date.tar

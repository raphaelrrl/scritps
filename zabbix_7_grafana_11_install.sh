#!/bin/bash
#Autor: Raphael Rodrigues
#Homologado para Debian 12 LTS
#Baixe o script - wget https://raw.githubusercontent.com/raphaelrrl/scritps/refs/heads/main/zabbix_7_grafana_11_install.sh
#Execute o comando-  chmod +x zabbix_7_grafana_11_install.sh - para permissão de execução.
#Execute o comando-  chmod 777 zabbix_7_grafana_11_install.sh - para permissão de total ao script.
#Em seguida execute o comando-  ./zabbix_7_grafana_11_install.sh

# Upgrade do SO
apt update
apt upgrade
cd /tmp
rm *deb*
rm /tmp/finish

# Instalacao dependencias bibliotecas essenciais
apt install -y wget build-essential
apt install -y apache2 apache2-utils
apt install -y libapache2-mod-php php php-mysql php-cli php-pear php-gmp php-gd
apt install -y php-bcmath  php-curl php-xml php-zip
apt install -y mariadb-server mariadb-client
apt install -y snmpd snmp snmptrapd libsnmp-base libsnmp-dev
apt install -y screen figlet toilet cowsay
useradd zabbix

##bem, chegou a hora de baixar o nosso zabbix.
cd /tmp
wget https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_7.0-2+debian12_all.deb
dpkg -i zabbix-release_7.0-2+debian12_all.deb
sleep 3
apt update -y ; apt upgrade -y
apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent

##agora que o nosso banco de dados esta instalado vamos criar a base que ira receber os dados do zabbix.
export DEBIAN_FRONTEND=noninteractive
mariadb -uroot -e "create database zabbix character set utf8mb4 collate utf8mb4_bin";
mariadb -uroot -e "create user 'zabbix'@'localhost' identified by 'p455w0rd'";
mariadb -uroot -e "grant all privileges on zabbix.* to 'zabbix'@'localhost'";
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -pp455w0rd zabbix
echo 'Populando base de dados zabbix, pode demorar um pouco dependendo do hardware'
sleep 10
sed -i 's/# DBPassword=/DBPassword=p455w0rd/' /etc/zabbix/zabbix_server.conf

##timezone php, execute o commando abaixo, em seguida edite que arquivo de configuração etc/zabbix/apache.conf como descrito abaixo:
timedatectl set-timezone America/Sao_Paulo
sed -i 's/# php_value date.timezone Europe\/Riga/php_value date.timezone America\/Sao_Paulo/g' /etc/apache2/conf-enabled/zabbix.conf
sed -i 's#/var/www/html#/usr/share/zabbix#g' /etc/apache2/sites-available/000-default.conf
systemctl enable zabbix-server zabbix-agent
systemctl restart zabbix-server zabbix-agent apache2
systemctl status zabbix-server

# Grafana Install oficial repo
apt-get install -y apt-transport-https
apt-get install -y software-properties-common
wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
sleep 10
mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | tee -a /etc/apt/sources.list.d/grafana.list
apt-get update -y
apt-get install -y grafana

#Instalando Datasource Zabbix
grafana-cli plugins install alexanderzobnin-zabbix-app
grafana-cli plugins update alexanderzobnin-zabbix-app
systemctl daemon-reload
systemctl start grafana-server
systemctl enable grafana-server
touch /tmp/finish

#O pulo do gato para o perfeito monitoramento, ajustes SNMP
wget http://ftp.de.debian.org/debian/pool/non-free/s/snmp-mibs-downloader/snmp-mibs-downloader_1.5_all.deb
Sleep 20
dpkg -i snmp-mibs-downloader_1.5_all.deb
sleep 20
apt-get -y install smistrip

#ajuste mib quebrada
wget http://pastebin.com/raw.php?i=p3QyuXzZ -O /usr/share/snmp/mibs/ietf/SNMPv2-PDU

clear
figlet -c senha BD p455w0rd
figlet -c FINALIZADO!
systemctl status zabbix-server | grep Active

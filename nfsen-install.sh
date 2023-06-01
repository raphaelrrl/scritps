#!/bin/bash
#Instalação NFsen NETFLOW

#NFDUMP
apt update
apt upgrade
apt install nfdump
nfdump -V

#atualização de bibliotecas
apt install -y build-essential autoconf make gcc wget
apt install -y rrdtool mrtg librrds-perl librrdp-perl librrd-dev
apt install -y libmailtools-perl bison 
apt install -y flex libpcap-dev php libsocket6-perl apache2 php-common apache2-utils
apt install -y libapache2-mod-php libtool dh-autoreconf pkg-config libbz2-dev byacc doxygen graphviz
apt install -y libapache2-mod-php php php-mysql php-cli php-pear php-gmp php-gd 
apt install -y php-bcmath  php-curl php-xml php-zip

#instalar modulo MCPAN
perl -MCPAN -e 'install socket6'

#INSTALAR  NFSEN
cd /usr/src/
wget https://github.com/p-alik/nfsen/archive/refs/tags/nfsen-1.3.8.tar.gz
tar -zxvf nfsen-1.3.8.tar.gz
cd /usr/src/nfsen-nfsen-1.3.8
cp etc/nfsen-dist.conf /etc/nfsen.conf

#editar o arquivo de configuração do nfsen

nano /etc/nfsen.conf

$BASEDIR = "/opt/nfsen";
$HTMLDIR = "/var/www/nfsen/";
$PREFIX = '/usr/bin';
$USER = "www-data";
$WWWGROUP = "www-data";
%sourcers = (
	'BGP'	=>{ 'port' => '9995', 'col' =>'#0000ff', 'type' => 'netflow' },
	'BNG'	=>{ 'port' => '9996', 'col' =>'#00ffff', 'type' => 'netflow' },
);

#ajustar RRD linha 76, alterar versão para 1.8
nano /usr/src/nfsen-nfsen-1.3.8/libexec/NfSenRRD.pm

 if ( $rrd_version >= 1.2 && $rrd_version < 1.8 ) {

# instale o NFsen no linux

mkdir /opt/nfsen

./install.pl /etc/nfsen.conf

ps aux | grep nfsen

# ajuste Aliase no apache
 nano /etc/apache2/sites-enabled/000-default.conf
Alias /nfsen	/var/www/nfsen/

# aplicar link simbolico
ln -s /var/www/nfsen/nfsen.php /var/www/nfsen/index.php

#startar o serviço

service apache2 reload
/opt/nfsen/bin/nfsen start

# enviar fluxo via Probe NETFLOW ( host linux )

apt install fprobe


#localizar binarios variavel path
which nfdump

#adicionar outra sourcer
nano /etc/nfsen.conf
%sources = (
    'P-BGP-BORDA'    => { 'port' => '9995', 'col' => '#0000ff', 'type' => 'netflow' },
    'CE-IPOE'    => { 'port' => '9996', 'col' => '#00ffff', 'type' => 'netflow' },
);

/opt/nfsen/bin/nfsen reconfig
/opt/nfsen/bin/nfsen stop
/opt/nfsen/bin/nfsen start

#!/bin/bash
# Wanguard - Guia de preparacao, instalacao e uso
#=================================================================================
# Site do fabricante:  https://www.andrisoft.com/
#
#Agradecimentos:
# Proprietario desta conta git 
#    Raphael Rodrigues
#      Contatos:
#         - Site..........: https://raphaelisp.com.br/
#         - Site..........: https://flowspec.net.br/
#         - WhatsApp / Tel: +55 22 99999-0768
#         - Youtube.......: https://www.youtube.com/@raphaelisp
#         - Instagram.....: https://www.instagram.com/raphaelispconnect/
#
#     Patrick Brandao, Gran-Mestre Supremo em Network e Linux User Power Full
#      Contatos:
#         - Site..........: http://patrickbrandao.com/
#         - WhatsApp / Tel: +55 31 9 8405-2336
#         - Youtube.......: https://www.youtube.com/@tol83
#         - Instagram.....: https://www.instagram.com/patrickbrd
#
# Referencias:
#    https://www.andrisoft.com/de/download
#    https://www.andrisoft.com/download/debian11
#    https://www.andrisoft.com/download/debian12
#
# Requisitos para uso do software:
#    Maquina virtual ou Baremetal (recomendado, ligar direto na borda)
#    RAM......: 128 GB (se for VM, colocar como reservada)
#    CPU......: o maximo possivel de nucleos
#    HD.......: 256 GB (minimo, SSD ou NVME)
#    REDE.....: 10gbit  (1 gb e' inadimissivel)
#
#
#  Voce pode instalar em maquina/vm inferior: pode
#  Voce deve: NAO. Vai faltar recursos e rapidez
#             e normalmente quem faz esse tipo de
#             porcaria sempre culpa o software,
#             nunca a sua propria avareza.
#
#  Sistema operacional: Debian 12 64 bits
#    Utilize a ISO 64 bits NETINSTALL
#
#  Durante a instalacao:
#    - IP fixo SEMPRE, nao use DHCP
#    - Coloque IPv4 e IPv6
#    - NAO INSTALE X-WINDOW (Interface Grafica)
#    - Instale: SSH e ferramentas do sistema
#
# Recomendado para maximo de aproveitamento:
#   - opcional....: gerencia em interface de 1g ou 10g (NAO MANDE FLOW AQUI)
#   - obrigatorio.: colega de FLOW numa interface de 10g
#   - opcional....: porta de 10g ou 40/100g para receber trafego de port-mirror
#
# Para melhor visualizacao do trafego de entrada, e' recomendado
# que todos os links cheguem em um switch de alta capacidade
# e que sejam entregues ao BGP ligado nesse switch
# Esse tipo de ligacao permite que o port-mirror seja ativado
# no switch para enviar uma copia fiel do trafego de entrada
# ao WanGuard
# O Flow/NetFlow/sFlow nao e' o trafego de entrada real, e sim
# um resumo/amostra/abstracao do trafego.
# Obrigatorio: sincronismo NTP em TODOS os equipamentos envolvidos
# Recomendado: usar o WanGuard como servidor NTP para que o relogio
#              dele e de todos os equipamentos sejam sincronizados
#              fielmente

# Begin :)
apt-get -y update
apt-get -y upgrade

# Instalar pacotes
apt-get -y install apt-transport-https
apt-get -y install wget
apt-get -y install gnupg
apt-get -y install python3-pysimplesoap
apt-get -y install ntp unzip curl net-tools tcpdump

#SNMP
apt install -y snmpd snmp snmptrapd libsnmp-base libsnmp-dev

#SMP - NUMA
apt-get -y install numactl coreutils htop numactl numatop

# time-zone
apt-get -y install ntpdate
apt-get -y install systemd-timesyncd

# Sincronismo data hora
timedatectl set-timezone America/Sao_Paulo
ntpdate a.ntp.br

# config de data hora:
 (
 echo
 echo '[Time]'
 echo 'NTP=200.160.0.8'
 echo 'FallbackNTP=2001:12ff::8'
 echo '#RootDistanceMaxSec=5'
 echo '#PollIntervalMinSec=32'
 echo '#PollIntervalMaxSec=2048'
 echo
 ) > /etc/systemd/timesyncd.conf

 # Atualizar timectl:
 timedatectl set-ntp true
 timedatectl status

# repositorios
wget -O - https://www.andrisoft.com/andrisoft.gpg.key | gpg --dearmor --yes --output /usr/share/keyrings/andrisoft-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/andrisoft-keyring.gpg] https://www.andrisoft.com/files/debian12 bookworm main" > /etc/apt/sources.list.d/andrisoft.list

# Instalar pacotes essenciais:
 apt update
 apt-get -y install wanbgp
 apt-get -y install python3-pip
 apt-get -y install exabgp
 apt-get -y install wanconsole
 apt-get -y install wansupervisor
 apt-get -y install wanfilter

# Fixar timezone no PHP 8 (coloque o mesmo timezone do sistema)
 sed -i 's#;date.timezone.*#date.timezone=America/Sao_Paulo#g' \
 /etc/php/8.2/apache2/php.ini \
 /etc/php/8.2/cli/php.ini

# Config do apache:
 sed -i 's#/var/www/html#/opt/andrisoft/webroot#g' /etc/apache2/sites-available/000-default.conf
 ln -sf /opt/andrisoft/etc/andrisoft_apache.conf /etc/apache2/conf-enabled/andrisoft_apache.conf

# Ajustes MariaDB safe.cnf
    (
        echo
        echo '[mysqld_safe]'
        echo 'nice = 0'
        echo 'skip_log_error'
        echo 'syslog'
        echo "timezone='America/Sao_Paulo'"
        echo
    ) > /etc/mysql/mariadb.conf.d/50-mysqld_safe.cnf

# Adicionando senha root
mysqladmin -u root password W4ngu4rd1!

# Ajustes MariaDB server.cnf
(
        echo
        echo '[server]'
        echo
        echo '[mysqld]'
        echo 'user                    = mysql'
        echo 'pid-file                = /run/mysqld/mysqld.pid'
        echo 'basedir                 = /usr'
        echo 'datadir                 = /var/lib/mysql'
        echo 'tmpdir                  = /tmp'
        echo 'lc-messages-dir         = /usr/share/mysql'
        echo 'lc-messages             = en_US'
        echo 'skip-name-resolve'
        echo 'skip-external-locking'
        echo 'bind-address            = 127.0.0.1'
        echo 'bind-address            = IP-DO-SERVIDOR'
        echo 'expire_logs_days        = 10'
        echo 'character-set-server    = utf8mb4'
        echo 'collation-server        = utf8mb4_general_ci'
        echo
        echo '# Tuning, 4x'
        echo 'key_buffer_size         = 512M'
        echo 'max_allowed_packet      = 1G'
        echo 'thread_stack            = 2048K'
        echo 'thread_cache_size       = 32'
        echo 'max_connections         = 512'
        echo 'table_cache             = 512'
        echo
        echo 'table_open_cache        = 512'
        echo 'sort_buffer_size        = 2M'
        echo 'read_buffer_size        = 2M'
        echo 'read_rnd_buffer_size    = 8M'
        echo 'myisam_sort_buffer_size = 64M'
        echo 'query_cache_size        = 32M'
        echo 'thread_concurrency      = 16'
        echo
        echo '[embedded]'
        echo '[mariadb]'
        echo '[mariadb-10.5]'
        echo
    ) > /etc/mysql/mariadb.conf.d/50-server.cnf

# Reiniciar MariaDB
    systemctl restart mariadb

# ou limpar Config mariadb
# mysqladmin -u root password W4ngu4rd1!
# sed -i '/^[^#]/ s/\(^.*bind-address.*$\)/#\ \1/' /etc/mysql/mariadb.conf.d/50-server.cnf
# Instalar o banco de dados inicial do MariaDB
# mysql_secure_installation

# Reiniciar servicos dependentes:
 systemctl restart mariadb
 systemctl restart apache2

# Sem banner:
    echo -n > /etc/motd
    rm -f /etc/update-motd.d/10-uname

    # Colocar banner bonitinho!
    (
        echo
        echo
        echo '      888       888                    .d8888b.                                888 '
        echo '      888   o   888                   d88P  Y88b                               888 '
        echo '      888  d8b  888                   888    888                               888 '
        echo '      888 d888b 888  8888b.  88888b.  888        888  888  8888b.  888d888 .d88888 '
        echo '      888d88888b888     "88b 888 "88b 888  88888 888  888     "88b 888P"  d88" 888 '
        echo '      88888P Y88888 .d888888 888  888 888    888 888  888 .d888888 888    888  888 '
        echo '      8888P   Y8888 888  888 888  888 Y88b  d88P Y88b 888 888  888 888    Y88b 888 '
        echo '      888P     Y88A "T88888R 88I  88C  CY8888P88  KY88888 "Y88888B R88     DY88888 '
        echo
        echo
    ) > /etc/motd

# Criar login andrisoft
    mysql -uroot -pW4ngu4rd1! -e "CREATE DATABASE andrisoft;"

    # Criar usuario andrisoft
    mysql -uroot -ptulipasql -e "CREATE USER IF NOT EXISTS 'andrisoft'@'localhost' identified by 'W4ngu4rd1!';"
    mysql -uroot -ptulipasql -e "GRANT ALL PRIVILEGES ON andrisoft.* TO 'andrisoft'@'localhost' IDENTIFIED BY 'W4ngu4rd1!';"
    mysql -uroot -ptulipasql -e "FLUSH PRIVILEGES;"
    mysql -uroot -ptulipasql -e "UNINSTALL PLUGIN validate_password;" 2>/dev/null

    # Criar database andrisoft
    mysql -uroot -pW4ngu4rd1! andrisoft < /opt/andrisoft/sql/andrisoft.sql
    mysql -uroot -pW4ngu4rd1! andrisoft < /opt/andrisoft/sql/as_numbers.sql

# *** Escolha um dos modos de config (modo 1 e' mais rapido, so colar!)


    # CONFIG MODO 1 - Manualmente:
    # - IPs para escutar a interface web
    #    V4IP=$(ip -o -4 ro get 1.2.3.4      | sed 's#.*src.###g' | cut -f1 -d' ')
    #    V6IP=$(ip -o -6 ro get 2804:fada::1 | sed 's#.*src.###g' | cut -f1 -d' ')
    #    IPBIND=$(echo $V4IP $V6IP)

    # - IP do banco de dados MariaDB: (loopback lo0 de gerencia, ou mover para outro servidor)
        IPBIND=IP-DO-SERVIDOR
        echo $IPBIND > /opt/andrisoft/etc/dbhost.conf

    # - Senha do usuario andrisoft para acessar o banco de dados (database: andrisoft)
        echo -n wanguardsql > /opt/andrisoft/etc/dbpass.conf

    # - Testar acesso ao banco de dados com as credenciais do wanguard:
        mysql -uandrisoft -pW4ngu4rd1! andrisoft -e "SHOW TABLES;"

    # - IP Wan de gerencia:
    #    mysql -uandrisoft -pwanguardsql andrisoft -e "update wanserver set ip = 'IP-DO-SERVIDOR' where ip = '127.0.0.1';"

#Configuração do wanguard Wizard interativo
# /opt/andrisoft/bin/install_console
# /opt/andrisoft/bin/install_supervisor
systemctl start WANsupervisor
systemctl enable WANsupervisor

#influxdb
wget https://dl.influxdata.com/influxdb/releases/influxdb_1.8.10_amd64.deb
dpkg -i ./influxdb_1.8.10_amd64.deb
cp /etc/influxdb/influxdb.conf /etc/influxdb/influxdb.conf.backup
cp /opt/andrisoft/etc/influxdb.conf /etc/influxdb/influxdb.conf
systemctl restart influxdb
/opt/andrisoft/bin/install_influxdb


# SysCTL - Tuning universal
#=================================================================================

    (
        echo  "net.core.rmem_default=31457280"
        echo  "net.core.wmem_default=31457280"
        echo  "net.core.rmem_max=134217728"
        echo  "net.core.wmem_max=134217728"
        echo  "net.core.netdev_max_backlog=250000"
        echo  "net.core.optmem_max=33554432"
        echo  "net.core.default_qdisc=fq"
        echo  "net.core.somaxconn=4096"
    )  >  /etc/sysctl.d/051-net-core.conf

    (
        echo "net.ipv4.tcp_sack = 1"
        echo "net.ipv4.tcp_timestamps = 1"
        echo "net.ipv4.tcp_low_latency = 1"
        echo "net.ipv4.tcp_max_syn_backlog = 8192"
        echo "net.ipv4.tcp_rmem = 4096 87380 67108864"
        echo "net.ipv4.tcp_wmem = 4096 65536 67108864"
        echo "net.ipv4.tcp_mem = 6672016 6682016 7185248"
        echo "net.ipv4.tcp_congestion_control=htcp"
        echo "net.ipv4.tcp_mtu_probing=1"
        echo "net.ipv4.tcp_moderate_rcvbuf =1"
        echo "net.ipv4.tcp_no_metrics_save = 1"
    )  >  /etc/sysctl.d/052-net-tcp-ipv4.conf

    echo "net.ipv4.ip_local_port_range=1024 65535" >  /etc/sysctl.d/056-port-range-ipv4.conf

    echo "net.ipv4.ip_default_ttl=128"             >  /etc/sysctl.d/062-default-ttl-ipv4.conf

    (
        echo "net.ipv4.neigh.default.gc_interval = 30"
        echo "net.ipv4.neigh.default.gc_stale_time = 60"
        echo "net.ipv4.neigh.default.gc_thresh1 = 4096"
        echo "net.ipv4.neigh.default.gc_thresh2 = 8192"
        echo "net.ipv4.neigh.default.gc_thresh3 = 12288"

        echo "net.ipv4.ipfrag_high_thresh=4194304"
        echo "net.ipv4.ipfrag_low_thresh=3145728"
        echo "net.ipv4.ipfrag_max_dist=64"
        echo "net.ipv4.ipfrag_secret_interval=0"
        echo "net.ipv4.ipfrag_time=30"
    )  >  /etc/sysctl.d/063-neigh-ipv4.conf

    (
        echo "net.ipv6.neigh.default.gc_interval = 30"
        echo "net.ipv6.neigh.default.gc_stale_time = 60"
        echo "net.ipv6.neigh.default.gc_thresh1 = 4096"
        echo "net.ipv6.neigh.default.gc_thresh2 = 8192"
        echo "net.ipv6.neigh.default.gc_thresh3 = 12288"

        echo "net.ipv6.ip6frag_high_thresh=4194304"
        echo "net.ipv6.ip6frag_low_thresh=3145728"
        echo "net.ipv6.ip6frag_secret_interval=0"
        echo "net.ipv6.ip6frag_time=60"
    )  >  /etc/sysctl.d/064-neigh-ipv6.conf

    echo  "net.ipv4.conf.default.forwarding=1"   >  /etc/sysctl.d/065-default-foward-ipv4.conf
    echo  "net.ipv6.conf.default.forwarding=1"   >  /etc/sysctl.d/066-default-foward-ipv6.conf
    echo  "net.ipv4.conf.all.forwarding=1"       >  /etc/sysctl.d/067-all-foward-ipv4.conf
    echo  "net.ipv6.conf.all.forwarding=1"       >  /etc/sysctl.d/068-all-foward-ipv6.conf
    echo  "net.ipv4.ip_forward=1"                >  /etc/sysctl.d/069-ipv4-forward.conf

    (
        echo "fs.file-max = 3263776"
        echo "fs.aio-max-nr=3263776"
        echo "fs.mount-max=1048576"
        echo "fs.mqueue.msg_max=128"
        echo "fs.mqueue.msgsize_max=131072"
        echo "fs.mqueue.queues_max=4096"
        echo "fs.pipe-max-size=8388608"
    )  >  /etc/sysctl.d/072-fs-options.conf

    echo  "vm.swappiness=1"                      >  /etc/sysctl.d/073-swappiness.conf
    echo  "vm.vfs_cache_pressure=50"             >  /etc/sysctl.d/074-vfs-cache-pressure.conf

    echo  "kernel.panic=3"                       >  /etc/sysctl.d/081-kernel-panic.conf
    echo  "kernel.threads-max=1031306"           >  /etc/sysctl.d/082-kernel-threads.conf
    echo  "kernel.pid_max=262144"                >  /etc/sysctl.d/083-kernel-pid.conf
    echo  "kernel.msgmax=327680"                 >  /etc/sysctl.d/084-kernel-msgmax.conf
    echo  "kernel.msgmnb=655360"                 >  /etc/sysctl.d/085-kernel-msgmnb.conf
    echo  "kernel.msgmni=32768"                  >  /etc/sysctl.d/086-kernel-msgmni.conf

    echo  "vm.min_free_kbytes = 32768"           >  /etc/sysctl.d/087-kernel-free-min-kb.conf


 # Aplicar:
    sysctl -p 2>/dev/null 1>/dev/null
    sysctl --system 2>/dev/null 1>/dev/null

# Licenciamento do WanGuard
#=================================================================================

    # Acesse:
    #    https://www.andrisoft.com/store/user/form
    #
    # E crie uma conta.
    #
    # Confirme o email de ativacao da conta
    #

    # Acesse seu servidor via HTTP (nao e' https), porta 80
    #
    # Vai aparecer a tela do wanguard com o checklist da instalacao
    #
    # Observe o botao "Upload License Key", precisa usar ele para
    # fazer upload da licenca.
    #


    # 1 - Licenca TRIAL
    #     Acesse:        https://www.andrisoft.com/trial/registration
    #
    #     Preencha o formulario com dados empresariais
    #
    #     Aguarde a licenca de teste no seu e-mail
    #


    # 2 - Licencas:
    #     Acesse:       https://www.andrisoft.com/store/software
    #
    # Tipos:
    # - Wanguard Sensor license (~ $595)
    #   - base inicial para anti-ddos
    #   - monitoramento passivo (netflow, snmp)
    #   - flowspec-bgp e blackhole-bgp
    #
    # - Wanguard Filter license (~ $995)
    #   - permite usar o recurso netfilter/iptables para filtragem
    #     no proprio wanguard
    #
    # - Wansight Sensor license (~ $300)
    #   - somente monitoramento passivo (netflow, snmp)
    #
    # - DPDK Engine license (~ $1410)
    #   - semelhante ao Filter mas com DPDK (40g+ trafego)
    #


    # Primeiro acesso: http://IP-DO-SERVIDOR/
    # Login e senha padrao:
    #    admin / changeme
    #
    # Mudar senha em:
    # - no canto SUPERIOR DIREITO, click no icone do login "admin"
    #   tem o menu "Change Password"
    #   > informe a nova senha


# Peering entre o roteador e o WanGuard para injecao BGP (ipv4 e flowspec)
#=================================================================================

# Exemplo HUAWEI (ignore erros)
#---------------------------------------------------------------------------------

route-policy ACCEPT-ALL permit node 65535
#
route-policy DENY-ALL deny node 65535
#

bgp 253344
    peer 45.255.128.2 as-number 253344
    peer 45.255.128.2 description WANGUARD-IPV4
    peer 45.255.128.2 connect-interface LoopBack0
    peer 45.255.128.2 timer connect-retry 1

    ipv4-family unicast
        peer 45.255.128.2 enable
y
        peer 45.255.128.2 route-policy ACCEPT-ALL import
        peer 45.255.128.2 route-policy DENY-ALL export
        peer 45.255.128.2 advertise-community
        peer 45.255.128.2 advertise-ext-community
        peer 45.255.128.2 advertise-large-community
        peer 45.255.128.2 reflect-client

    ipv4-family flow
        peer 45.255.128.2 enable
y
        peer 45.255.128.2 redirect ip rfc-compatible
        peer 45.255.128.2 route-policy ACCEPT-ALL import
        peer 45.255.128.2 route-policy DENY-ALL export
        peer 45.255.128.2 validation-disable
        peer 45.255.128.2 advertise-community
        peer 45.255.128.2 advertise-large-community
        peer 45.255.128.2 reflect-client
        route validation-mode include-as
#
commit
run save
y

# Sincronizar data/hora via NTP (usar o proprio WanGuard como NTP Server)
#========================================================================

# Obs 1: (somente na VS-ADMIN)
# Obs 2: (ignorar erros no "y", as vezes pede, as vezes nao pede)

ntp-service server disable
y

ntp-service ipv6 server disable
y

ntp-service server source-interface all disable
y
ntp-service ipv6 server source-interface all disable
y

# IP de origem padrao de requisicoes NTP:
ntp-service      source-interface LoopBack 0
ntp-service ipv6 source-interface LoopBack0


# Usando WanGuard local - Via IPv4
ntp-service unicast-peer      45.255.128.2 source-interface LoopBack 0

# Usando WanGuard local - Via IPv6
ntp-service unicast-peer ipv6 2804:fada:beba:cafe::2 source-interface LoopBack0


# Via IPv4 em NTP publico (use uma interface que tenha ipv4 publico navegavel)
#ntp-service unicast-peer 200.160.0.8   source-interface LoopBack0
#ntp-service unicast-peer 200.189.40.8  source-interface LoopBack0

# Via IPv6 em NTP publico (use uma interface que tenha ipv6 global navegavel)
#ntp-service unicast-peer ipv6 2001:12F8:9:1::8  source-interface LoopBack0
#ntp-service unicast-peer ipv6 2001:12FF::8      source-interface LoopBack0


commit
run save
y

# Config netstream geral
#========================================================================

ip netstream as-mode 32
ip netstream timeout active 1
ip netstream timeout inactive 15
ip netstream tcp-flag enable
ip netstream export version ipfix peer-as bgp-nexthop ttl
ip netstream export template sequence-number fixed
ip netstream export index-switch 32
ip netstream export template timeout-rate 1
ip netstream sampler fix-packets 1000 inbound
ip netstream sampler fix-packets 1000 outbound
ip netstream export template option sampler
ip netstream export template option application-label
#
ipv6 netstream as-mode 32
ipv6 netstream timeout active 1
ipv6 netstream timeout inactive 15
ipv6 netstream tcp-flag enable
ipv6 netstream export version ipfix peer-as bgp-nexthop ttl
ipv6 netstream export template sequence-number fixed
ipv6 netstream export index-switch 32
ipv6 netstream export template timeout-rate 1
ipv6 netstream sampler fix-packets 1024 inbound
ipv6 netstream sampler fix-packets 1024 outbound
ipv6 netstream export template option sampler
#

# Ativar CPU para flow na controladora
#========================================================================

# F1A:
  slot 1
    ip netstream sampler to slot self
    ipv6 netstream sampler to slot self
  commit


# NE 8000 M8
  slot 10
    ip netstream sampler to slot self
    ipv6 netstream sampler to slot self
  commit

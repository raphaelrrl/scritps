#!/bin/sh
#fastnetmon-adv
# instalação dependencias
apt install wget tcpdump net-tools zip curl -y

# instalação fastnetmon adv
wget https://install.fastnetmon.com/installer -Oinstaller
 chmod +x installer
 ./installer -activation_coupon KUTPOLAVTAHoDyiNuHbaCiRviSeNvuKuBvuReVkaLaTfiQiFbeToYtoNeVqiZoPd

# integração grafana nativa
wget https://install.fastnetmon.com/installer -Oinstaller
 chmod +x installer
 ./installer -install_graphic_stack
 
 # habilitando clickhouse
 fcli set main clickhouse_metrics true
 fcli set main clickhouse_metrics_host 127.0.0.1
 fcli set main clickhouse_metrics_database fastnetmon
 fcli set main clickhouse_metrics_export_top_hosts true
 fcli commit

# verificando exportação
fcli show system_counters|grep click
clickhouse_metrics_writes_total                            2044855 
clickhouse_metrics_writes_failed   
 
 # Se realizar upgrade, Você precisa instalar a versão avançada primeiro. Depois disso, você pode executar este comando -import_community_edition_configuration
wget https://install.fastnetmon.com/installer -Oinstaller
 chmod +x instalador
 ./installer -import_community_edition_configuration

# CLI Temos três categorias de configuração:
main – toolkit wide options
bgp – BGP configuration options
hostgroup – custom threshold configurations for different networks

# comandos CLI fastnetmon
fcli
show <category> <option_name>
set <category> <option_name> value
set <category> <option_name> (disable|enable)
delete <category> <option_name> value_for_remove
show <category_name>

#Primeiros passos
fcli set main networks_list 100.64.0.0/10
fcli commit

 fcli set main netflow enable
 fcli set main netflow_ports 2055
 fcli set main netflow_host 0.0.0.0
 fcli set main netflow_host ::
 fcli set main netflow_sampling_ratio 1
fcli set main average_calculation_time 60
fcli commit

#verificar pacotes recebidos
fcli show system_counters|grep duration
 fcli show netflow9_packets_per_device
 fcli show ipfix_packets_per_device 

#Analisar trafego
fastnetmon_client
 fcli show total_traffic_counters
 fcli show total_traffic_counters_v6
 fcli show network_counters
 fcli show network_counters_v6
 fcli show host_counters bytes outgoing
 fcli show host_counters_v6 bytes outgoing
 fcli show single_host_counters 10.1.2.3
 fcli show single_host_counters_v6 beef::1

# threshold global
 fcli set hostgroup global threshold_mbps 100
 fcli set hostgroup global ban_for_bandwidth enable
 fcli set hostgroup global enable_ban enable
 fcli set hostgroup global enable_ban_incoming enable
 fcli set hostgroup global ban_for_udp_pps true
 fcli set hostgroup global threshold_udp_pps 1000
 fcli set hostgroup global ban_for_tcp_pps true
 fcli set hostgroup global threshold_tcp_pps 1000
 fcli set hostgroup global ban_for_udp_pps	true
 fcli set hostgroup global  threshold_udp_pps 1000
 fcli commit
 
#Criando grupos
fcli set main enable_total_hostgroup_counters enable
 fcli set hostgroup CDN
 fcli set hostgroup CDN calculation_method total
 fcli set hostgroup CDN networks 100.64.0.0/24
 fcli set hostgroup CDN networks 100.65.0.0/24
 fcli commit
 fcli show hostgroup_counters_total

 # threshold Grupos
 fcli set hostgroup CDN threshold_mbps 100
 fcli set hostgroup CDN ban_for_bandwidth enable
 fcli set hostgroup CDN enable_ban enable
 fcli set hostgroup CDN enable_ban_incoming enable
 fcli set hostgroup CDN ban_for_udp_pps true
 fcli set hostgroup CDN threshold_udp_pps 1000
 fcli set hostgroup CDN ban_for_tcp_pps true
 fcli set hostgroup CDN threshold_tcp_pps 1000
 fcli set hostgroup CDN ban_for_udp_pps	true
 fcli set hostgroup CDN threshold_udp_pps 1000
 fcli commit
 
# Estabelecendo peer bgp
 fcli set main gobgp enable
 fcli set bgp RT01-BGP
 fcli set bgp RT01-BGP local_asn 65001
 fcli set bgp RT01-BGP remote_asn 65001
 fcli set bgp RT01-BGP local_address 100.125.0.18
 fcli set bgp RT01-BGP remote_address 100.125.0.19
 fcli set bgp RT01-BGP ipv4_unicast enable
 fcli set bgp RT01-BGP ipv6_unicast enable
 fcli set bgp RT01-BGP ipv4_flowspec enable
 fcli set bgp RT01-BGP active enable
 fcli commit

# verificando as sessoes BGP
gobgp global rib -a ipv4
gobgp neighbor
 fcli set reload_bgp


# RTBH 
 fcli set main enable_ban enable
 fcli set main enable_ban_ipv6 enable
 fcli set main unban_enabled true
 fcli set main ban_time 600
 fcli set main ban_details_records_count 5

#Habilitando anuncios BGP
fcli set main gobgp_announce_host enable
 fcli set main gobgp_communities_host_ipv4 65001:666
 fcli set main gobgp_next_hop_host_ipv4 192.0.2.1

#Setando RTBH manual
 fcli set blackhole 11.22.33.44
 fcli show blackhole
 
 #deletando regra
 fcli delete blackhole 312e3232-2e33-332e-3434-000000000000
 fcli show blackhole
 
#Habilitando anuncios Flowspec
 fcli set bgp RT01-BGP ipv4_flowspec enable
 fcli set main gobgp_flow_spec_announces enable
 fcli set main gobgp_flow_spec_default_action discard
 fcli set main gobgp_flow_spec_rate_limit_value 1000
 fcli commit
 fcli show flowspec  

# Flowspec  manual
 fcli set flowspec  '{ "source_prefix": "4.0.0.0/32", "destination_prefix": "100.64.0.0/32", "destination_ports": [ 80 ], "source_ports": [ 53, 5353 ], "packet_lengths": [ 777, 1122 ], "protocols": [ "tcp" ], "fragmentation_flags": [ "is-fragment", "dont-fragment" ], "tcp_flags": [ "syn" ], "action_type": "rate-limit", "action": { "rate": 1024 } }'

#deletando regra
 fcli delete blackhole 312e3232-2e33-332e-3434-000000000000
 fcli show  flowspec


# Comando para visualização
#Get system counters
show system_counters

#Get total traffic counters
show total_traffic_counters

#Interfaces management Get interfaces list
show interfaces

#List all host groups:
show hostgroup

#Create new host group with name “new_group”
set hostgroup new_group

#Delete host group with name:
delete hostgroup new_group

#Check option value for cerain host group
show hostgroup global networks

#Set option for certain host group:
show hostgroup host_group_name networks

#Lookup host group for specified IP address
show ip_hostgroup 11.22.33.44

#White lists
 fcli set main networks_whitelist 11.22.33.44/32

referencias;

https://fastnetmon.com/install/
https://fastnetmon.com/docs-fnm-advanced/
https://fastnetmon.com/docs-fnm-advanced/advanced-quick-start/
https://fastnetmon.com/docs-fnm-advanced/migration-from-community-edition-to-advanced/
https://fastnetmon.com/docs-fnm-advanced/advanced-cli-reference/
https://fastnetmon.com/docs-fnm-advanced/advanced-visual-traffic/
https://fastnetmon.com/docs-fnm-advanced/fastnetmon-configuration-for-netflow-and-ipfix/
https://fastnetmon.com/docs-fnm-advanced/fastnetmon-threshold-types/
https://fastnetmon.com/docs-fnm-advanced/per-hostgroup-thresholds/
https://fastnetmon.com/docs-fnm-advanced/fastnetmon-advanced-licensing-server/
https://fastnetmon.com/docs-fnm-advanced/fastnetmon-bgp-flow-spec-configuration/
https://fastnetmon.com/docs-fnm-advanced/fastnetmon-advanced-bgp-blackhole-automation/
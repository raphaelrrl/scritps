#!/bin/bash
#atualizar SO	
	apt update
 	apt upgrade
	apt autoremove

#Instalação Openvas	
	apt install openvas
	
#iniciar serviço - 
	gvm-setup
	
#ajustar acesso via endereço IP externo
	nano /usr/lib/systemd/system/greenbone-security-assistant.service
	 systemctl daemon-reload
	gvm-check-setup
	sudo -u _gvm greenbone-nvt-sync --rsync
	greenbone-feed-sync --type GVMD_DATA
	greenbone-feed-sync --type SCAP
	greenbone-feed-sync --type CERT
	greenbone-scapdata-sync
	greenbone-certdata-sync
	gvm-feed-update
	gvm-start
		

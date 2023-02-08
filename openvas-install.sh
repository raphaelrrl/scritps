#!/bin/bash
#atualizar SO	
	apt update
    apt upgrade
    apt autoremove

#Instalação Openvas	
	apt install openvas
	
#iniciar serviço - '494d515d-d14b-4d84-abe0-4281fdb3d72d'
	gvm-setup
	sudo gvm-check-setup
	
	greenbone-feed-sync --type GVMD_DATA
	greenbone-feed-sync --type SCAP
	greenbone-feed-sync --type CERT
	sudo -u _gvm greenbone-nvt-sync --rsync
	sudo greenbone-scapdata-sync
	sudo greenbone-certdata-sync
	gvm-feed-update
		
#ajustar acesso via endereço IP externo
	nano /usr/lib/systemd/system/greenbone-security-assistant.service
	 systemctl daemon-reload
	 gvm-start

#!/bin/bash
#atualizar SO	
	apt update
    apt upgrade
    apt autoremove

#Instalação Openvas	
	apt install openvas
	
#iniciar serviço - '494d515d-d14b-4d84-abe0-4281fdb3d72d'
	gvm-setup
		
#ajustar acesso via endereço IP externo
	nano /usr/lib/systemd/system/greenbone-security-assistant.service
	 systemctl daemon-reload
	 gvm-start
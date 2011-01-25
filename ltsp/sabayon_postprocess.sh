#!/bin/bash
#=======================================================================
# Sript per la corretta applicazione delle modifiche ai profili Sabayon
#   a causa di un probabile bug di sabayon, alcune modifiche apportate
#   ai profili esistenti non vengono applicate
#   occorre quindi cancellare alcuni files per fare in modo che vengano
#   rigenerati al successivo login grafico
#
# 
# v. 1.0 - (it) 04/10/2010 - ivan@riminilug.it
#
# ---------------------------------------------------------------------
# Per l'utilizzo dello script passare come parametro il gruppo relativo
# al prfilo modificato. 
# Nel caso della scuola GeoCenci i due gruppi utilizzati sono :
#  - teachers
#  - students
#
#====================================================================
set -u

#------------------------------------------------
# Controllo se l'esecutore ha i permessi di root
#------------------------------------------------
if [ `id -u` -ne 0 ]
then
  echo "[EEE] ERRORE: solo l'utente root puo' eseguire questo script"
  exit 1
fi

#------------------------------------------------
# Controllo dei parametri
#------------------------------------------------
if [ "$#" -gt 0 ]
then
	grp_name=$1
	
else
  echo "[EEE] Errore: Passare il nome del gruppo!"
  echo "Uso: $0 nome_gruppo_sabayon"
  exit 1
fi



#----------------------------------------------------
# Per ogni utente appartenente al gruppo specificato
# eseguo i comandi di pulizia del profilo
#
#----------------------------------------------------
usr_list=`grep $grp_name /etc/group|awk -F":" {'print $4}'`
echo ">>> Processo il gruppo [$grp_name] che contiene i seguenti utenti:"
echo "    [$usr_list]"

ifstmp=$IFS
IFS=","
for usr_name in $usr_list
do

	
	#----------------------------------------------------
	# NOTA:
	# nel caso ci si accorgesse che sono necessarie altre 
	# operazioni, aggiungerle qui
	# ATTENZIONE A QUELLO CHE SI FA !!!
	#----------------------------------------------------
	
	echo ">>> Elimino i files della directory : /home/$usr_name/.config/menus/*"
	rm -Rf /home/$usr_name/.config/menus/*
	

done

IFS=$ifstmp
			
echo "----------------------------------------------------"
echo "Script completato con successo!"
echo "----------------------------------------------------"

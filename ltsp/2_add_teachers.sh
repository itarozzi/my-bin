#!/bin/bash
#====================================================================
# Sript per la creazione degli utenti insegnanti
# nel server LTSP della scuola
#
#
# v. 1.0 - (it) 10/09/2010 - ivan@riminilug.it
# v. 1.1 - (it) 21/09/2010 - ivan@riminilug.it
#		- Aggiungo insegnanti al gruppo $classe
#		- Consento Info Utente nulle e segnalo lo skip
# v. 1.2 - (it) 26/01/2011 - ivan@riminilug.it
#   - possibilità di leggere da stdin (se non uso --undo)
#   - lo UID non viene più forzato!
#     (per compatibilità con i vecchi files il campo ID deve essere mantenuto)
#
#
#
# Formato file  elenco_insegnanti.txt:
# ------------------------------------
#ID;cognome;nome;nome_utente;elenco classi [separati da spazio]
#====================================================================
set -u

#----------------------------------------------------
# Visualizza messaggio per info utente non complete
# 
#------------------------------------------
msg_params() {

  record="$1";
  field=$2;
  skip=$3;
  if [[ skip -eq 1 ]];
  then
    echo "***ERRORE: Il campo NR $field è mancante";
    echo "   EE ==> Salto la riga : [$record]";
  else
    echo "***ATTENZIONE: Il campo NR $field è nullo";
    echo "   WW ==> Aggiungo comunque la  riga : [$record]";
  fi
}

#------------------------------------------
# Undo delle operazioni eseguite
# da usare con cautela e consapevolezza!
#------------------------------------------
undo() {

while read riga 
do
	if [[ "$riga" =~ ^\# ]]; then continue; fi

	cognome=`echo $riga|awk -F";" {'print $2}'`
	nome=`echo $riga|awk -F";" {'print $3}'`
	username=`echo $riga|awk -F";" {'print $4}'`
	classi=`echo $riga|awk -F";" {'print $5}'`

	username=$(echo $username | tr [:upper:] [:lower:])

	if [ -z "$username" ]; then continue; fi

	deluser --remove-home $username

done <  "$FILENAME"	

}

#------------------------------------------------
# Controllo se l'esecutore ha i permessi di root
#------------------------------------------------
if [ `id -u` -ne 0 ]
then
	echo "ERRORE: solo l'utente root puo' eseguire questo script"
	exit 1
fi

#------------------------------------------------
# Controllo dei parametri
#------------------------------------------------
if [ "$#" -gt 0 ]
then
  
	if [ "$1" = "--undo" ]
	then
    FILENAME=$2
		undo
		exit 0
	else
    FILENAME=$1
	fi
else 
  FILENAME=/dev/stdin
fi



#-------------------------------------------
# Processo il file contenente gli insegnanti
#-------------------------------------------
if [ -e $FILENAME ] 
then
	echo "Elaboro il file  $FILENAME"
else
	echo "ERRORE: impossibile trovare il file  $FILENAME"
	exit 2
fi

ERR=""
while read riga 
do
  #skip delle righe di commento nel file
  if [[ "$riga" =~ ^\# ]]; then continue; fi
  #skip righe vuote
  if [ -z "$riga" ]; then continue; fi      
  #------------------------------------------
  # aggiungo gli utenti insegnanti
  #------------------------------------------
  id=`echo $riga|awk -F";" {'print $1}'`
  cognome=`echo $riga|awk -F";" {'print $2}'`
	nome=`echo $riga|awk -F";" {'print $3}'`
  username=`echo $riga|awk -F";" {'print $4}'`
	classi=`echo $riga|awk -F";" {'print $5}'`


	if [ -z "$id" ]; then msg_params        $riga 1 1; ERR="1"; continue; fi
	if [ -z "$cognome" ]; then msg_params   $riga 2 1; ERR="2"; continue; fi
	if [ -z "$nome" ]; then msg_params      $riga 3 1; ERR="3"; continue; fi
	if [ -z "$username" ]; then msg_params  $riga 4 1; ERR="4"; continue; fi
	if [ -z "$classi" ]; then msg_params    $riga 5 1; ERR="5"; continue; fi

  # Trasformo il nome utente tutto lowercase
	username=$(echo $username | tr [:upper:] [:lower:])

 
	echo "----------------------------------------------------"
	echo "Aggiungo l'insegnante: $cognome $nome [$username] "
	
	if  grep -q ^"$username:" /etc/passwd
	then
		echo "ERRORE: L' utente $username risulta gia' presente!"
		echo "        impossibile procedere con la creazione automatica"
		continue;
	fi

	adduser  --force-badname --disabled-login --gecos "$cognome $nome"  $username

  #Imposta la password di default
	#nota!: la password preimpostata corrisponde al nome utente
	#       prevedere di modificarla al primo accesso o anche successivamente
	echo $username:$username | chpasswd

	#-------------------------------------------------------------
	# aggiungo gli insegnanti al gruppo teachers
  # Note!: non viene assegnato come gruppo primario altrimenti
  #        sabayon da' problemi 
	#-------------------------------------------------------------
  addgroup $username teachers


	#-------------------------------------------------------------
	# aggiungo gli insegnanti ai gruppi corrispondenti alle classi 
	#-------------------------------------------------------------
	for classe in $classi
	do
	  adduser $username t_$classe
	  adduser $username $classe
	done


	#=== imposto i permessi privati per la home ===
	chmod 750 /home/$username

	#=== Creo il link alla directory condivisa degli insegnanti ===
	ln -sf /home/teachers /home/$username/teachers



done < "$FILENAME"

			
if [ -z "$ERR" ]; then			
  echo "----------------------------------------------------"
  echo "Script completato con successo!"
  echo "----------------------------------------------------"
else
  echo "----------------------------------------------------"
  echo "Script completato con errore!"
  echo "----------------------------------------------------"
  exit 50
fi

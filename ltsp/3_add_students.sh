#!/bin/bash
#====================================================================
# Sript per la creazione degli utenti studenti
# nel server LTSP della scuola
#
# 
# v. 1.0 - (it) 10/09/2010 - ivan@riminilug.it
# v. 1.1 - (it) 21/09/2010 - ivan@riminilug.it
#		- Consento Info Utente nulle e segnalo lo skip
#
# 
# -------------------------------------------------------------------
#
# Formato file  elenco_alunni.txt:
# ------------------------------------
#ID;cognome;nome;nome_utente;classe
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
  echo "Errore: Passare il nome del file da processare"
  echo "Uso: 2_add_students.sh [--undo] nomefile.csv"
  exit 2
fi



#-------------------------------------------
# Processo il file contenente gli alunni
#-------------------------------------------
if [ -e $FILENAME ] 
then
	echo "Elaboro il file  $FILENAME"
else
	echo "ERRORE: impossibile trovare il file  $FILENAME"
	exit 2
fi

while read riga 
do
	#skip delle righe di commento nel file
	if [[ "$riga" =~ ^\# ]]; then continue; fi

	#------------------------------------------
	# aggiungo gli utenti alunni
	#------------------------------------------
  id=`echo $riga|awk -F";" {'print $1}'`
	cognome=`echo $riga|awk -F";" {'print $2}'`
	nome=`echo $riga|awk -F";" {'print $3}'`
  username=`echo $riga|awk -F";" {'print $4}'`
	classe=`echo $riga|awk -F";" {'print $5}'`

	if [ -z "$id" ]; then msg_params        $riga 1 1; continue; fi
	if [ -z "$cognome" ]; then msg_params   $riga 2 0; continue; fi
	if [ -z "$nome" ]; then msg_params      $riga 3 0; continue; fi
	if [ -z "$username" ]; then msg_params  $riga 4 1; continue; fi
	if [ -z "$classe" ]; then msg_params    $riga 5 1; continue; fi

  # Trasformo il nome utente tutto lowercase
	username=$(echo $username | tr [:upper:] [:lower:])

  # Assegno UID = 3000 + ID

  let uid="3000+$id"
 
	echo "----------------------------------------------------"
	echo "Aggiungo l'alunno: $cognome $nome [$username] -> UID $uid"
	
	if  grep -q ^"$username:" /etc/passwd
	then
		echo "ERRORE: L' utente $username risulta gia' presente!"
		echo "        impossibile procedere con la creazione automatica"
		continue;
	fi

	adduser  --force-badname --uid $uid --disabled-login --gecos "$cognome $nome"  $username

  #Imposta la password di default
	#nota!: la password preimpostata corrisponde al nome utente
	#       prevedere di modificarla al primo accesso o anche successivamente
	echo $username:$username | chpasswd

	#-------------------------------------------------------------
	# aggiungo gli alunni al gruppo students
  # Note!: non viene assegnato come gruppo primario altrimenti
  #        sabayon da' problemi 
	#-------------------------------------------------------------
  addgroup $username students


	#-------------------------------------------------------------
	# aggiungo lo studente al gruppo della corrispondente classe
	#-------------------------------------------------------------
  adduser $username $classe


	#=== imposto i permessi privati per la home ===
	chmod 2770 /home/$username
	chown $username:t_$classe /home/$username

	#=== Creo il link alla directory condivisa di classe -> deve esistere! ===
	ln -sf /home/$classe /home/$username/classe

done < "$FILENAME"

			
echo "----------------------------------------------------"
echo "Script completato con successo!"
echo "----------------------------------------------------"

#!/bin/bash
#====================================================================
# Sript per la creazione dei gruppi <classe> e delle directory
# accessorie nel server LTSP della scuola
#
# 
# v. 1.0 - (it) 10/09/2010 - ivan@riminilug.it
#
# -------------------------------------------------------------------
# Per l'utilizzo dello script passare come parametro l'elenco delle
# classi separate da spazilassi [separati da spazio]
#
#
# TODO:
# Trasformare UNDO in DELETE o creare script a parte
#====================================================================
set -u

#------------------------------------------
# Undo delle operazioni eseguite
# da usare con cautela e consapevolezza!
#------------------------------------------
undo() {

# !!!!!!!!@@@@@!!!!!! Eliminiare o trasformare in DELETE !!!!
  echo "UNDO non ancora implementato!"

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
    undo
    exit 0
  #else
    #echo "Errore: Parametro non supportato!"
    #exit 1
  fi
else
  echo "Errore: Passare almeno un nome di classe!"
  exit 1
fi



#-------------------------------------------
# Aggiungo un gruppo per ogni classe passata
# e un gruppo per gli insegnanti di tale classe
#-------------------------------------------

echo "Params: " $@

for nome_classe in $@
do
  echo "Aggiungo il gruppo: ["$nome_classe"]" 
  addgroup $nome_classe

  echo "Aggiungo il gruppo: [t_"$nome_classe"]" 
  addgroup t_$nome_classe

done



#------------------------------------------------
# creo una directory in /home per ogni classe 
#------------------------------------------------
for nome_classe in $@
do
  dir_name=/home/$nome_classe
  echo "Creo la directory: ["$dir_name"]" 
  mkdir -m2770 $dir_name
  chown root:$nome_classe $dir_name
done

#------------------------------------------------
# creo la directory /home/teachers 
#------------------------------------------------

#dovrebbe già esistere, ma per sicurezza lo ricreo
addgroup teachers

dir_name=/home/teachers
echo "Creo la directory: ["$dir_name"]" 
mkdir -m2770 $dir_name
chown root:teachers $dir_name
			
echo "----------------------------------------------------"
echo "Script completato con successo!"
echo "----------------------------------------------------"

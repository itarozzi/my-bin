#!/bin/bash

#------------------------------------------------
# Controllo se l'esecutore ha i permessi di root
#------------------------------------------------
if [ `id -u` -ne 0 ]
then
  zenity --error --text "ERRORE:\nsolo l'utente root puo' eseguire questo script"
	exit 1
fi

export DIALOG='

     <vbox>
        <text><label>"Creazione Nuovo Account: Studente"</label></text>

        <frame Nome>
            <entry>
                <variable>NOME</variable>
            </entry>
        </frame>
        
        <frame Cognome>
            <entry>
                <variable>COGNOME</variable>
            </entry>
        </frame>

        <frame Classe>
          <list>
            <variable>CLASSE</variable>
            
             <item>classe1f</item>
             <item>classe3f</item>

             <item>classe1g</item>
             <item>classe2g</item>
             <item>classe3g</item>

             <item>classe1h</item>
             <item>classe2h</item>
             <item>classe3h</item>
          </list>
        </frame>

       <hbox>
         <button ok></button>
         <button cancel></button>
       </hbox>
     </vbox>'

I=$IFS; IFS=""
for STATEMENTS in  $(gtkdialog --program DIALOG); do
  eval $STATEMENTS
done
IFS=$I

if [ "$EXIT" = "OK" ]; then
  if [ -z "$NOME$COGNOME" ]; then
    zenity --error --text "Errore nell'inserimento\ndi Nome e Cognome dell'utente" 
    exit 10
  fi  
             
  echo "Valori Inseriti:$NOME;$COGNOME;$CLASSE"
  echo "1;$NOME;$COGNOME;$NOME.$COGNOME;$CLASSE" | ./3_add_students.sh
  
  if [ "$?" -eq 0 ]; then
    zenity --info --text "Inserimento eseguito!" 
  else
    zenity --error --text "Errore nell'esecuzione dello script\ndi inserimento utenti" 
  fi
else
  echo "You pressed the Cancel button."
fi


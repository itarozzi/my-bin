#!/bin/bash
# Usate, modificate, riscrivete questo script come vi pare.
# se vi succede qualcosa di brutto a causa di questo script,
# io non c'ero, e se c'ero dormivo, ergo: sono cavoli vostri. chiaro?

# versione: 0.2.4.4

## CONFIGURAZIONE UTENTE
tries=5			#tentativi di scaricare ogni file
timeout=10		#tempo massimo di attesa risposta per lo scaricamento (secondi)
player="vlc"		#nome del player video.
output="si"		#mandare a video i messaggi del player? (si/no)
background="no"	#mandare il player in background, in modo da aver disponibile il terminale?

#per salvare gli stream, usate il vostro player preferito.
#per mplayer ad esempio, basta modificare la variabile "player" a:
# player="mplayer -dumpfile stream.wmv -dumpstream"

############ PROGRAMMA REALE ################
############ NON MODIFICARE! ################
TDIR="`echo ${0}|rev|cut -d '/' -f 1|rev`"
mkdir /tmp/${TDIR} 2>/dev/null
chmod 777 /tmp/${TDIR} 2>/dev/null
RND=$RANDOM
NOTFOUND=""
for command in wget curl sed grep awk tail head dialog python base64; do
	if [ -z "`which $command 2>/dev/null`" ]; then
		NOTFOUND="`echo "$NOTFOUND $command"`"
	fi
done
if [ -n "`which kdialog 2>/dev/null`" ]; then
	USEKDIALOG="true"
else
	USEKDIALOG="false"
fi
if [ -n "$NOTFOUND" ]; then
	echo "Comandi non trovati:"
	echo $NOTFOUND
	exit 1
fi
USERAGENT='Mozilla/5.0 (X11; U; Linux i686; it; rv:1.9.0.6) Gecko/2009011912 Firefox/3.5.5'
PLAYERCMD="`echo $player|awk -F " " '{print $1}'`"
if [ -z "`which $PLAYERCMD 2>/dev/null`" ]; then
	echo "Player $PLAYERCMD non trovato!"
	exit 1
fi
unset PLAYERCMD
case $output in
	[Ss][Ii])
		;;
	[Nn][Oo])
		;;
	*)
		echo "La variabile \"output\" ammette solo"
		echo "I valori \"si\" e \"no\""
		exit 1
		;;
esac
case $background in
	[Ss][Ii])
		;;
	[Nn][Oo])
		;;
	*)
		echo "La variabile \"background\" ammette solo"
		echo "I valori \"si\" e \"no\""
		exit 1
		;;
esac
help () {
	echo "Script per la visualizzazione dei canali presenti su rai.tv"
	echo "senza il plugin Silverlight di Microsoft o Moonlight di Novell"
	echo "Creato da Luke88 -- luke88 _at_ slacky.it"
	echo -e "\nUso:\t$0 chiave_ricerca\tcerca canale nella lista"
	echo -e "\t$0 tutti\t\tlista completa dei canali"
	echo ""
	echo "per configurare player e comportamenti del player"
	echo "cambiare le variabili all'inizio di questo script"
	echo "con il vostro editor preferito"
	echo -e "\nlo script non porta con se' garanzie di qualsiasi tipo"
}
update () {
	echo "scarico la lista dei canali...."
	rm /tmp/${TDIR}/${RND}.xml &>/dev/null
	wget --header="viaurl: http://www.rai.tv" -U "$USERAGENT" --tries=$tries --timeout=$timeout -O /tmp/${TDIR}/${RND}.xml www.rai.tv/dl/RaiTV/videoWall/PublishingBlock-5566288c-3d21-48dc-b3e2-af7fbe3b2af8.xml &>/dev/null
	if [ ! -s /tmp/${TDIR}/${RND}.xml ]; then
		echo "Download fallito! controlla la connessione internet e rilancia il programma"
		exit 1
	fi
	rm /tmp/${TDIR}/${RND}.tmp &>/dev/null
	grep -B 1 '<url>' /tmp/${TDIR}/${RND}.xml|sed /--/d | sed s/^\ *// > /tmp/${TDIR}/${RND}.tmp
	rm /tmp/${TDIR}/${RND}.xml &>/dev/null
	sed -i s/\&apos\;/\'/g /tmp/${TDIR}/${RND}.tmp
	sed -i 's/\&#224\;/à/g' /tmp/${TDIR}/${RND}.tmp
	sed -i 's/\&#225\;/à/g' /tmp/${TDIR}/${RND}.tmp
	sed -i 's/\&#232\;/è/g' /tmp/${TDIR}/${RND}.tmp
	sed -i 's/\&#233\;/é/g' /tmp/${TDIR}/${RND}.tmp
	sed -i 's/\&#236\;/ì/g' /tmp/${TDIR}/${RND}.tmp
	sed -i 's/\&#237\;/ì/g' /tmp/${TDIR}/${RND}.tmp
	sed -i 's/\&#242\;/ò/g' /tmp/${TDIR}/${RND}.tmp
	sed -i 's/\&#242\;/ò/g' /tmp/${TDIR}/${RND}.tmp
	sed -i 's/\&#249\;/ù/g' /tmp/${TDIR}/${RND}.tmp
	sed -i s/\&amp\;/\\\&/g /tmp/${TDIR}/${RND}.tmp
	sed -i s/\&quot\;/\'/g /tmp/${TDIR}/${RND}.tmp
	sed -i s/\&#039\;/\'/g /tmp/${TDIR}/${RND}.tmp
	COUNTER=0
	rm /tmp/${TDIR}/${RND}.canali &>/dev/null
	while read line ; do
		let "NUM=$COUNTER % 2"
		if [ $NUM -eq 0 ]; then
			let "NUM=$COUNTER % 20"	#facciamo vedere qualcosa a schermo...
			if [ $NUM -eq 0 ]; then
				let "NUM=$COUNTER/2"	#ogni 10 stream diciamo a quanti siamo...
				echo -n $NUM
			else
				echo -n "."
			fi
			echo -en $line|awk -F '"' '{print $2}' >> /tmp/${TDIR}/${RND}.canali	#metti il nome dello stream in cache
		else
			echo -en $line|awk -F '<url>' '{print $2}'|awk -F '</url>' '{print $1}' >> /tmp/${TDIR}/${RND}.canali	#metti l'indirizzo dello stream in cache
			echo "==" >> /tmp/${TDIR}/${RND}.canali	#non è realmente necessario, ma se qualcuno si vuole vedere la lista selza usare lo script
		fi								#fa comodo avere una lista leggibile
		let COUNTER++
	done < /tmp/${TDIR}/${RND}.tmp
	echo ""
	rm /tmp/${TDIR}/${RND}.tmp &>/dev/null
}
check_dwn () {
	if [ ! -s /tmp/${TDIR}/${RND}.tmp ]; then
		echo "Download fallito! controlla la connessione internet e rilancia il programma"
		exit 1
	fi
}
giveRND () {
	expr $(echo $RANDOM) % 1234
}
play () {
ID=`expr match "$STREAM" '.*=\([0-9]*\)'`
DATE=`curl -A "$AGENT" http://videowall.rai.it/cgi-bin/date`
DATE=(`echo $DATE | sed -e 's/[:-]/ /g'`)
DAY=${DATE[0]}
MONTH=${DATE[1]}
YEAR=${DATE[2]}
HOUR=${DATE[3]}
MIN=${DATE[4]}
SEC=${DATE[5]}

TOKENSTRING=`echo "${YEAR};${ID};${DAY}-${MONTH}-$(giveRND)-${HOUR}-${MIN}-${SEC}-$(giveRND)"`
MASKEDSTRING=`python << EOF
import sys
import base64
import random

a="$TOKENSTRING"
b=random.randint(0,30)
x=""
for ch in a:
  x+=(chr(ord(ch)^b))
x+=";"
x+=str(b)
i=0
j=0
y=""
b="uotyawehtgnikcehc"
for ch in x:
  y+=(chr(ord(x[i])^ord(b[j])))
  i+=1
  j+=1
  if j > 16:
    j=0
x=base64.encodestring(str.encode(y)).decode()
x=base64.encodestring(y)
print x
EOF`

# grazie mille a http://flavio.tordini.org/dirette-raitv-senza-silverlight-o-moonlight
	if [ -z "`echo $STREAM|grep 'mms://'`" ]; then
		#uff... tiriamo fuori lo stream da incasinamenti vari....
		rm /tmp/${TDIR}/${RND}.tmp &>/dev/null
		wget --header="viaurl: http://www.rai.tv" -U "$USERAGENT" --header "ttAuth:${MASKEDSTRING}" --tries=$tries --timeout=$timeout --spider  "$STREAM" -O /dev/null 1> /dev/null 2> /tmp/${TDIR}/${RND}.tmp	#a volte il link è un file flv.
		check_dwn
		TMP="`tail -n 2 /tmp/${TDIR}/${RND}.tmp|grep 'flv'`"	#che sembra essere solo un video....
		rm /tmp/${TDIR}/${RND}.tmp
		if [ -z "$TMP" ]; then
			wget --header="viaurl: http://www.rai.tv" -U "$USERAGENT" --header "ttAuth:${MASKEDSTRING}" --tries=$tries --timeout=$timeout -O /tmp/${TDIR}/${RND}.tmp "$STREAM" &>/dev/null
			check_dwn
			if [ -z "`grep 'http://' /tmp/${TDIR}/${RND}.tmp`" ]&&[ -z "`grep 'mms://' /tmp/${TDIR}/${RND}.tmp`" ]; then
				#mi è capitato che alcuni link portino nel vuoto
				echo "(muove la mano)--Tu *NON* vuoi vedere questo canale"
				rm /tmp/${TDIR}/${RND}.tmp
				exit 1
			else
				if [ -n "`grep 'mms://' /tmp/${TDIR}/${RND}.tmp`" ]; then
					STREAM="`cat /tmp/${TDIR}/${RND}.tmp|sed s/\\"/\\\n/g|grep 'mms://'`" #"`"`" #ripristino colorazione vim
				elif [ -n "`grep wmv /tmp/${TDIR}/${RND}.tmp`" ]; then
					STREAM="`cat /tmp/${TDIR}/${RND}.tmp |sed s/\\"/\\\\n/g|grep wmv`" #"`"`" #ripristino colorazione vim
				else
					STREAM="`cat /tmp/${TDIR}/${RND}.tmp |sed s/\\"/\\\n/g|grep 'http://'`" #"`"`" #ripristino colorazione vim
					#############################################################
					# Modifica 04/07/2009 - jigen74
					# lo stream ha una forma del tipo:
					# <ASX VERSION="3.0"><ENTRY><REF HREF="..." /></ENTRY></ASX>
					# per cui per recuperare l'url corretto leggo il contenuto di HREF
					#############################################################
					if [ -n "`echo $STREAM|grep 'HREF'`" ]; then
						STREAM="`echo $STREAM|awk -F 'HREF="' '{print $2}'|awk -F '"' '{print $1}'`"
					elif [ -n "`echo $STREAM|grep '"'`" ]; then
						STREAM="`echo $STREAM|awk -F '"' '{print $2}'`"
					fi
					rm /tmp/${TDIR}/${RND}.tmp
					wget --header="viaurl: http://www.rai.tv" -U "$USERAGENT" --header "ttAuth:${MASKEDSTRING}" --tries=$tries --timeout=$timeout --spider "$STREAM" -O /dev/null 1>/dev/null 2>/tmp/${TDIR}/${RND}.tmp
					check_dwn
					if [ -z "`tail -n 2 /tmp/${TDIR}/${RND}.tmp|grep 'flv'`" ]; then	#se NON è un flv...
						wget --header="viaurl: http://www.rai.tv" -U "$USERAGENT" --header "ttAuth:${MASKEDSTRING}" --tries=$tries --timeout=$timeout -O /tmp/${TDIR}/${RND}.tmp "$STREAM" &>/dev/null
						check_dwn
						if [ -n "`grep 'mms://' /tmp/${TDIR}/${RND}.tmp`" ]; then
							STREAM="`grep 'mms://' /tmp/${TDIR}/${RND}.tmp  |awk -F '"' '{print $2}'`"
						elif [ -n "`grep '.flv' /tmp/${TDIR}/${RND}.tmp`" ]; then
							STREAM="`cat /tmp/${TDIR}/${RND}.tmp`"
						########################################################
						# Modifica 04/07/2009 - jigen74
						# sostituito else con elif per il controllo 
						# dell'estensione .wmv
						# se lo stream non ha estensione non va modificato
						########################################################
						elif [ -n "`grep '.wmv' /tmp/${TDIR}/${RND}.tmp`" ]; then
							STREAM="`grep '.wmv' /tmp/${TDIR}/${RND}.tmp |awk -F '"' '{print $2}'`"
						fi
					fi
				fi
				#rm /tmp/${TDIR}/${RND}.tmp
			fi
		fi
	fi
	case $output in
		[Nn][Oo])
			case $background in
				[Nn][Oo])
					$player "$STREAM" &>/dev/null
					;;
				[Ss][Ii])
					$player "$STREAM" &>/dev/null &
					;;
			esac
			;;
		[Ss][Ii])
			case $background in
				[Nn][Oo])
					$player "$STREAM"
					;;
				[Ss][Ii])
					$player "$STREAM" &
					;;
			esac
			;;
	esac
}
if [ "$1" == "-h" ]||[ "$1" == "--h" ]||[ "$1" == "-help" ]||[ "$1" == "--help" ]; then
	help
	exit 0
fi
update
COUNTER=1
#costruiamo la lista variabili per il dialog.
#è una lista di elementi, del tipo
#nome1 "" help1 nome2 "" help2 ...
#il secondo elemento è volontariamente lasciato come lista vuota.
rm /tmp/${TDIR}/${RND}.list &>/dev/null

if [ "$1" == "tutti" ]||[ -z "$1" ]; then
	grep -v ^==$ /tmp/${TDIR}/${RND}.canali | \
	while read line; do
		case "$COUNTER" in
			1)
				if [ "$USEKDIALOG" == "true" ]; then
					TMP="`echo $line|sed 's/\ /_/g; s/_-_/_/g'`"
				else
					echo \"$line\" >> /tmp/${TDIR}/${RND}.list		#"# <--ripristino la colorazione per vim...
				fi
				COUNTER=2
				;;
			2)
				if [ "$USEKDIALOG" == "true" ]; then
					echo -e "`echo ${line}|sed s/\ /%20/g` ${TMP}" >> /tmp/${TDIR}/${RND}.list
				else
					echo -e \"\""\n"\"$line\" >> /tmp/${TDIR}/${RND}.list	#"# <--ripristino la colorazione per vim...
				fi
				COUNTER=1
				;;
		esac
	done
else
	grep -A 1 -i "$1" /tmp/${TDIR}/${RND}.canali | grep -v -- ^--$ | grep -v ^==$ |\
	while read line ; do
		case "$COUNTER" in
			0 )
				COUNTER=1 #serve solo per 'saltare un turno'
				;;
			1 )
				if [ -z "`echo $line|grep '://'`" ]; then	# se non è un url
					if [ "$USEKDIALOG" == "true" ]; then
						TMP="`echo $line|sed 's/\ /_/g; s/_-_/_/g'`"
					else
						echo \"$line\" >> /tmp/${TDIR}/${RND}.list		#"# <--ripristino la colorazione per vim...
					fi
					COUNTER=2
				else
					#abbiamo greppato l'indirizzo... non ce ne facciamo niente...
					COUNTER=0
				fi
				;;
			2 )
				if [ "$USEKDIALOG" == "true" ]; then
					echo -e "`echo ${line}|sed s/\ /%20/g` ${TMP}" >> /tmp/${TDIR}/${RND}.list
				else
					echo \"\" >> /tmp/${TDIR}/${RND}.list				#"#
					echo \"$line\" >> /tmp/${TDIR}/${RND}.list			#"# <--ripristino la colorazione per vim...
				fi
				COUNTER=1
				;;
		esac
	done
fi

if [ ! -s /tmp/${TDIR}/${RND}.list ]; then
	echo "Canale non trovato..."
	exit 0
fi
rm /tmp/${TDIR}/${RND}.reply &>/dev/null
while [ 1 ]; do
REPLY=""
	if [ "$USEKDIALOG" == "true" ]; then
		CONTINUE=0
		STREAM=`kdialog --title "Rai.tv Senza Silverlight" --menu "Lista canali disponibili" $(cat /tmp/${TDIR}/${RND}.list)`
		CONTINUE=$? 
		if [ "$CONTINUE" != "0" ]; then
			break;
		fi
	else
		while [ -z "$REPLY" ]; do
			dialog --title "Stream disponibili" --help-button --item-help --menu "scegli lo stream da aprire" 20 70 12 --file /tmp/${TDIR}/${RND}.list 2> /tmp/${TDIR}/${RND}.reply
			REPLY="`tail -n 1 /tmp/${TDIR}/${RND}.reply`"
			rm /tmp/${TDIR}/${RND}.reply &>/dev/null 
			if [ -n "`echo $REPLY|grep '^HELP '`" ]; then
				REPLY="`echo $REPLY|awk -F "HELP " '{print $2}'`" 	#"`" # <<-ripristino colorazione vim....
				NAME="`grep -B 2 "$REPLY" /tmp/${TDIR}/${RND}.list|head -n 1`"
				dialog --title "$NAME" --msgbox "Lo stream è all'indirizzo:\n$REPLY" 20 70
				REPLY=""
			elif [ -z "$REPLY" ]; then
				break;
			fi
		done
		clear
		if [ "$REPLY" == "" ]; then
			echo "Nessuno stream trovato per questa ricerca"
			break;
		fi
		STREAM="`grep -A 2 "$REPLY" /tmp/${TDIR}/${RND}.list|tail -n 1|awk -F '"' '{print $2}'`"
	fi
	play
done
rm /tmp/${TDIR}/${RND}.list   &>/dev/null
rm /tmp/${TDIR}/${RND}.canali &>/dev/null
rm /tmp/${TDIR}/${RND}.tmp    &>/dev/null
#controllo quanti processi ${0} sono attivi. dev'essere 2 perchè il controllo spawna un processo figlio.
if [ "`ps aux|grep ${0}|grep -v grep|wc -l`" == "2" ]; then
	rm -rf /tmp/${TDIR}
fi
echo ""


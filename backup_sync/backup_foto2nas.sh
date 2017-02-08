#! /bin/bash

if [ ! -d "/mnt/nas/multimedia/Foto/K7/" ]; then
	mount "/mnt/nas/multimedia"
fi

if [ ! -d "/mnt/nas/multimedia/Foto/K7/" ]; then
	echo "Problem mounting NAS"
	exit 10
fi

BACKUPDIR[2]="RAW/"
BACKUPDIR[0]="darktable_library.db"
BACKUPDIR[1]="digikam4.db"
echo "Executing backup"

for i in `seq 0 2`
do
	echo ${BACKUPDIR[i]}
	rsync -auvr --stats /media/DATI_MM/Foto/"${BACKUPDIR[i]}" /mnt/nas/multimedia/Foto/K7/
done



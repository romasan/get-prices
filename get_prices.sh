#!/bin/bash

STARTDATE=`date +'%d %b %G (%T)'`;
HASCHANGES=false;
for SOURCE in `ls -A ./sources/`;
do

	I=1;
	COUNT=`wc -l './sources/'$SOURCE'/list'`;
	
	CHANGESFILENAME=`echo './sources/'$SOURCE'/changes/'$STARTDATE | sed 's/\ /\_/g'`;
	
	for LINE in `cat './sources/'$SOURCE'/list' | sed 's/\ /\_/g'`;
	do
#		clear;
#		echo 'processing item: '$I' of '$COUNT;
		NAME=`echo $LINE | awk -F '\\;' '{print $1}'`;
		URL=`echo $LINE | awk -F '\\;' '{print $2}'`;
		
		COOKIE=`cat ./sources/$SOURCE/cookie`;
		
		PRICE=`curl -s --cookie $COOKIE	$URL | './sources/'$SOURCE'/filter.sh'`;

		if test -e './sources/'$SOURCE'/data/'$I; then
			LASTPRICE=`tail -1 './sources/'$SOURCE'/data/'$I | awk -F '\\;' '{print $1}'`
			if [ "$LASTPRICE" != "$PRICE" ]; then
				echo $PRICE';'$STARTDATE >> './sources/'$SOURCE'/data/'$I
				echo $I';'$NAME';'$LASTPRICE';'$PRICE >> $CHANGESFILENAME
				HASCHANGES=true
			fi
		else
			echo $NAME > './sources/'$SOURCE'/data/'$I
			echo $URL >> './sources/'$SOURCE'/data/'$I
			echo $PRICE';'$STARTDATE >> './sources/'$SOURCE'/data/'$I
# 		echo $I';'$NAME';NEW RECORD;'$PRICE >> $CHANGESFILENAME
# 		HASCHANGES=true
		fi
		I=$((I+1));
	done;

	if [ $HASCHANGES == true ]; then
		echo 'RUN' $STARTDATE 'with changes' >> './sources/'$SOURCE'/log'
		sh ./gen_json.sh
	else
		echo 'RUN' $STARTDATE >> './sources/'$SOURCE'/log'
	fi

done;

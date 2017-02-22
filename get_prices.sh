#!/bin/sh

STARTDATE=`date +'%d %b %G (%T)'`;

for SOURCE in `ls -A ./sources/`;
do

	I=1;
	
	CHANGESFILENAME=`echo './sources/'$SOURCE'/changes/'$STARTDATE'.txt' | sed 's/\ /\_/g'`;
	
	for LINE in `cat ./sources/$SOURCE/list | sed 's/\ /\_/g'`;
	do
		
		NAME=`echo $LINE | awk -F '\\;' '{print $1}'`;
		URL=`echo $LINE | awk -F '\\;' '{print $2}'`;
		
		COOKIE=`cat ./sources/$SOURCE/cookie`;
		
		PRICE=`curl -s --cookie $COOKIE	$URL | ./sources/$SOURCE/filter.sh`;
		
		if test -e './sources/$SOURCE/data/'$I; then
			LASTPRICE=`tail -1 './data/'$I | awk -F '\\;' '{print $1}'`
			if [ "$LASTPRICE" != "$PRICE" ]; then
				echo $PRICE';'$STARTDATE >> './sources/$SOURCE/data/'$I
				echo $I';'$NAME';'$LASTPRICE';'$PRICE >> $CHANGESFILENAME
			fi
		else
			echo $NAME > './sources/$SOURCE/data/'$I
			echo $URL >> './sources/$SOURCE/data/'$I
			echo $PRICE';'$STARTDATE >> './sources/$SOURCE/data/'$I
		fi
		I=$((I+1));
	done;

# if test -e $CHANGESFILENAME; then
# 	sh ./gen_json.sh
# 	echo 'RUN' $STARTDATE 'with changes' >> log;
# else
# 	echo 'RUN' $STARTDATE >> log;
# fi

done;

#!/bin/sh
I=1;
STARTDATE=`date +'%d %b %G (%T)'`;
CHANGESFILENAME=`echo './changes_'$STARTDATE'.txt' | sed 's/\ /\_/g'`;
for LINE in `cat list | sed 's/\ /\_/g'`;
do
	NAME=`echo $LINE | awk -F '\\;' '{print $1}'`;
	URL=`echo $LINE | awk -F '\\;' '{print $2}'`;
	PRICE=`curl -s --cookie 'city_path=spb' $URL | grep price_g | head -1 | awk -F '\\>' '{print $2}' | awk -F '\\&nbsp' '{print $1}' | sed 's/\ //g'`;
	if test -e './data/'$I; then
		LASTPRICE=`tail -1 './data/'$I | awk -F '\\;' '{print $1}'`
		if [ "$LASTPRICE" != "$PRICE" ]; then
			echo $PRICE';'$STARTDATE >> './data/'$I
			echo $I';'$NAME';'$LASTPRICE';'$PRICE >> $CHANGESFILENAME
		fi
	else
		echo $NAME > './data/'$I
		echo $URL >> './data/'$I
		echo $PRICE';'$STARTDATE >> './data/'$I
	fi
	I=$((I+1));
done;

if test -e $CHANGESFILENAME; then
	sh ./gen_json.sh
	# echo 'RUN' $STARTDATE 'changes('`wc -l`')' >> log;
	echo 'RUN' $STARTDATE 'with changes' >> log;
else
	echo 'RUN' $STARTDATE >> log;
fi

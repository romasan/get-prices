#!/bin/sh

FILE='./tmp';

echo '{"data":[' > $FILE; # start json

SOURCEINDEX=1;
for SOURCE in `ls -A ./sources/`;
do
	
	if [ $SOURCEINDEX -gt 1 ]; then
		echo "," >> $FILE;
	fi

	echo '{"name":"'$SOURCE'","positions":[' >> $FILE; # start source
	
	I=1;
	for LINE in `cat './sources/'$SOURCE'/list' | sed 's/\ /\_/g'`;
	do

		if [ $I -gt 1 ]; then
			echo "," >> $FILE
		fi

		NAME=`echo $LINE | awk -F '\\;' '{print $1}'`;
		echo '{"name":"'$NAME'",' >> $FILE; # start position
	
		URL=`echo $LINE | awk -F '\\;' '{print $2}'`;
		echo '"url":"'$URL'",' >> $FILE;
		echo '"id":"'$I'",' >> $FILE;

		echo '"rows":[' >> $FILE;
	
		ROWNUM=1;
		for ROW in `cat './sources/'$SOURCE'/data/'$I | sed 's/\ /\_/g'`;
		do
		
			if [ $ROWNUM -gt 3 ]; then
				echo ',' >> $FILE;
			fi

			if [ $ROWNUM -gt 2 ]; then
				PRICE=`echo $ROW | awk -F '\\;' '{print $1}'`;
				echo '{"price":"'$PRICE'",' >> $FILE; # start row
				DATE=`echo $ROW | awk -F '\\;' '{print $2}'`;
				echo '"date":"'$DATE'"}' >> $FILE; # end row
			fi

			ROWNUM=$((ROWNUM+1));
		done;

		echo ']}' >> $FILE; # end position

		I=$((I+1));
	done;

	echo ']}' >> $FILE; # end source

	SOURCEINDEX=$((SOURCEINDEX+1));
done;

echo ']}' >> $FILE; # end json

echo $(cat $FILE) | sed 's/\ //g' > './web/data.json';

rm $FILE;

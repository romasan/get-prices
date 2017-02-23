#!/bin/sh

I=1;

FILE='./tmp';

echo '{"data":[' > $FILE;                            # {

for LINE in `cat list | sed 's/\ /\_/g'`;
do

	if [ $I -gt 1 ]; then
		echo "," >> $FILE
	fi

	echo '{' >> $FILE;                                 # {{
	
	NAME=`echo $LINE | awk -F '\\;' '{print $1}'`;
	echo '"name":"'$NAME'",' >> $FILE;
	
	URL=`echo $LINE | awk -F '\\;' '{print $2}'`;
	echo '"url":"'$URL'",' >> $FILE;

	echo '"rows":[' >> $FILE;                          # {{[
	
	ROWNUM=1;
	for ROW in `cat './data/'$I | sed 's/\ /\_/g'`;
	do
		
		if [ $ROWNUM -gt 3 ]; then
			echo ',' >> $FILE;
		fi

		if [ $ROWNUM -gt 2 ]; then
			echo '{' >> $FILE;                             # {{[{
			PRICE=`echo $ROW | awk -F '\\;' '{print $1}'`;
			echo '"price":"'$PRICE'",' >> $FILE;
			DATE=`echo $ROW | awk -F '\\;' '{print $2}'`;
		# sdate=`echo $DATE | sed 's/\_/\ /g'`;
			echo '"date":"'$DATE'"' >> $FILE;
			echo '}' >> $FILE;                             # {{[{}
		fi

		ROWNUM=$((ROWNUM+1));
	done;


	echo ']}' >> $FILE;                               # {{[]}

	
	I=$((I+1));
done;
echo ']' >> $FILE;

# laslogdata=`tail -1 ./log`;
# if test -e './changes_'$lastlogdata; then
# 	echo '\,\"changes\"\:\['
# fi

echo '}' >> $FILE;                                  # {}

echo $(cat $FILE) | sed 's/\ //g' > /home/r/projects/dns_price/data.json;

rm $FILE;

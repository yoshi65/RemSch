#!/bin/zsh

# variable
local -A today_sche_list
local -a del
num=0
del_num=0
time=`date +"%k"`
original=`/usr/local/bin/icalBuddy -f -sd -nc eventsToday+1`
today_line=`echo $original | grep -n "today" | sed -e 's/:.*//g'`
tomorrow_line=`echo $original | grep -n "tomorrow" | sed -e 's/:.*//g'`
today_sche_list=(`echo $original | head -n $(($tomorrow_line-1)) | grep -n "\-.[0-9][0-9]:[0-9][0-9]" | awk '{print $1} {print $4}' | sed -e 's/:.*//g'`)

# keep full time of today's schedule
for i in `seq $(($today_line+2)) $(($tomorrow_line-1))`
do
	if [ `echo $original | awk "$i <= NR && NR <= $(($i+1))" | grep -c "•"` = 2 ] ; then
		today_line=$i
	fi
done

# get end time of today's schedule
for key in ${(k)today_sche_list}; do
	if test $today_sche_list[$key] -le $time; then
		num=$key
	fi
done

# delete ended schedule
if test $num -eq 0; then
	data=$original
else
	data=`echo $original | awk "NR <= $(($today_line+1)) || $num <= NR"`
fi

# delete extra notes
del=(`echo $data | grep -n "\-\:\:" | sed -e 's/:.*//g'`)
del_num=$((`echo $#del`/2))
for i in `seq 0 $(($del_num-1))`
do
	data=`echo $data | awk "NR < $del[$((($del_num-i)*2-1))] || $del[$((($del_num-i)*2))] < NR"`
done
echo $data

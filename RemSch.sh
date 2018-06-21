#!/bin/zsh

# variable
local -A today_sche_list
local -A opthash
local -a del
local -a opt
num=0
NUM=1
del_num=0
opt=(-sd)
time=`date +"%k%M"`
error_message="usage: ./RemSch.sh [-f] [-nc] [-num NUM]\n\nShow the remaining schedule of today from icalBuddy(http://hasseg.org/icalBuddy/)\n\noptional arguments:\n  -f\t\tFormat output\n  -nc\t\tNo calendar names\n  -num NUM\tPrint events occurring between today and NUM days into the future"

# check option
zparseopts -D -A opthash -- f nc num:
if [[ -n "$@" ]]; then
	echo $error_message
	exit 1
fi
if [[ -n "${opthash[(i)-f]}" ]]; then
	opt=($opt -f)
fi
if [[ -n "${opthash[(i)-nc]}" ]]; then
	opt=($opt -nc)
fi
if [[ -n "${opthash[(i)-num]}" ]]; then
	NUM=${opthash[-num]}
fi

# get original data
original=`icalBuddy $opt eventsToday+$NUM | sed -e '/\.\.\. - \.\.\./d'`
today_line=`echo $original | grep -n "today" | sed -e 's/:.*//g'`
tomorrow_line=`echo $original | grep -n "^tomorrow" | sed -e 's/:.*//g'`
if [[ $tomorrow_line == '' ]]; then
    tomorrow_line=`echo $original | grep -n "^day\ after\ tomorrow" | sed -e 's/:.*//g'`
fi
today_sche_list=(`echo $original | head -n $(($tomorrow_line-1)) | grep -n "\-\ [0-9]*:[0-9]*" | awk '{print $1} {print $4}' | sed -e 's/:\([0-9][0-9]\).*/\1/g;s/:.*//g'`)

# keep full time of today's schedule
for i in `seq $(($today_line+2)) $(($tomorrow_line-1))`
do
	if [ `echo $original | awk "$i <= NR && NR <= $(($i+1))" | grep -c "•"` = 2 ] ; then
		today_line=$(($i - 1))
	fi
done

# get end time of today's schedule
for key in ${(k)today_sche_list}; do
	if [ $today_sche_list[$key] -le $time ] && [ $num -le $key ]; then
		num=$key
	fi
done

# delete ended schedule
if test $num -eq 0; then
	data=$original
else
	data=`echo $original | awk "NR <= $(($today_line + 1)) || $num < NR"`
fi

# delete extra contents
del=(`echo $data | grep -n "\-\:\:" | sed -e 's/:.*//g'`)
del_num=$((`echo $#del`/2))
for i in `seq 0 $(($del_num-1))`
do
	data=`echo $data | awk "NR < $del[$((($del_num-i)*2-1))] || $del[$((($del_num-i)*2))] < NR"`
done
data=`echo $data | sed -e '/attendees/d'`

# display data
echo $data

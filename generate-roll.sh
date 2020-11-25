#!/bin/sh

[ -d temp ] && rm -r temp
mkdir -p temp/years

year_n=0

for file in $(ls posts-md); do
	date=$(echo $file | sed 's|\.md||')
	year=$(echo $date | sed 's|-.*||')

	if [ -z $prev_year ] || [ $year != $prev_year ]; then
		year_n=$(echo $year_n+1 | bc)
		echo "$year_n $year" >> temp/year_list
	fi
	cat html/roll/post-head.html | sed 's|<!-- date !-->|'$date'|' >> temp/years/$year
	pandoc posts-md/$file -f markdown -t html >> temp/years/$year
	cat html/common/back-to-top.html >> temp/years/$year
	
	prev_year=$year
done

./finish-years.sh roll

rm -r temp

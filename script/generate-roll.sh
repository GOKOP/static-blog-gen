#!/bin/sh

[ -d temp ] && rm -r temp
mkdir -p temp/years

year_n=0

for file in $(ls -r posts-md); do
	date=$(echo $file | sed 's|_.*||; s|\.md||')
	year=$(echo $date | sed 's|-.*||')
	html_file=$(echo $file | sed 's|\.md|.html|')

	if [ -z $prev_year ] || [ $year != $prev_year ]; then
		year_n=$(echo $year_n+1 | bc)
		echo "$year_n $year" >> temp/year_list
	fi
	sed 's|<!-- date !-->|'$date'|' html/roll/post-head.html > temp/top
	sed 's|<!-- post !-->|'$html_file'|' temp/top >> temp/years/$year
	pandoc posts-md/$file -f markdown -t html >> temp/years/$year
	cat html/common/back-to-top.html >> temp/years/$year
	
	prev_year=$year
done

script/finish-years.sh roll

rm -r temp

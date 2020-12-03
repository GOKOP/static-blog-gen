#!/bin/sh

[ ! -d temp/years ] && mkdir -p temp/years

year_n=0

for file in $(ls -r posts-md); do
	date=$(head -n1 temp/postdata/$file)
	[ $(wc -l < temp/postdata/$file) = 2 ] && edit_date=$(tail -n1 temp/postdata/$file)
	year=$(echo $date | sed 's|-.*||')
	html_file=$(echo $file | sed 's|\.md|.html|')

	if [ -z $prev_year ] || [ $year != $prev_year ]; then
		year_n=$(echo $year_n+1 | bc)
		echo "$year_n $year" >> temp/year_list
	fi
	sed 's|<!-- date !-->|'$date'|' html/roll/post-head.html > temp/top0

	if [ -z $edit_date ]; then
		sed 's|.*<!-- edit date !-->.*||' temp/top0 > temp/top1
	else
		sed 's|<!-- edit date !-->|'$edit_date'|' temp/top0 > temp/top1
	fi

	sed 's|<!-- post !-->|'$html_file'|' temp/top1 >> temp/years/$year
	cat temp/posts/$html_file >> temp/years/$year
	cat html/common/back-to-top.html >> temp/years/$year
	
	prev_year=$year
done

script/finish-years.sh roll

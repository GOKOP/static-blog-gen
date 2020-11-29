#!/bin/sh
# This is meant to be called only from within generate-index.sh or generate-roll.sh

[ -d site/$1 ] && rm -r site/$1
mkdir site/$1

for year in $(ls temp/years); do
	year_n=$(grep " $year" temp/year_list | awk '{print $1}')

	if [ $year_n = 1 ]; then
		sed 's|^.*<!-- next year !-->.*$||' html/$1/top.html > temp/top0
	else
		prev_year=$(grep "$(echo $year_n-1 | bc) " temp/year_list | awk '{print $2}')
		sed 's|<!-- next year !-->|'$prev_year'|g' html/$1/top.html > temp/top0
	fi

	next_year=$(grep "$(echo $year_n+1 | bc) " temp/year_list | awk '{print $2}')

	if [ -z $next_year ]; then
		sed 's|^.*<!-- prev year !-->.*$||' temp/top0 > temp/top1
	else
		sed 's|<!-- prev year !-->|'$next_year'|g' temp/top0 > temp/top1
	fi

	if [ $year_n = 1 ]; then
		sed 's|<!-- nav class !-->|nav-laft|' temp/top1 > temp/top2
	elif [ -z $next_year ]; then
		sed 's|<!-- nav class !-->|nav-right|' temp/top1 > temp/top2
	else
		 sed 's|<!-- nav class !-->|nav-both|' temp/top1 > temp/top2
	fi

	sed 's|<!-- year !-->|'$year'|' temp/top2 > temp/top3
	sed 's|<!-- title !-->|'$year'|' html/common/top-pre-css.html > temp/top4
	cat temp/top4 html/$1/css.html html/common/top-post-css.html temp/top3 temp/years/$year html/common/footer.html > site/$1/$year.html
done

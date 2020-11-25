#!/bin/sh
# This is meant to be called only from within generate-index.sh or generate-roll.sh

[ -d site/$1 ] && rm -r site/$1
mkdir site/$1

for year in $(ls temp/years); do
	year_n=$(grep " $year" temp/year_list | awk '{print $1}')

	if [ $year_n = 1 ]; then
		cat html/$1/top.html | sed 's|^.*<!-- prev year !-->.*$||' > temp/top0
	else
		prev_year=$(grep "$(echo $year_n-1 | bc) " temp/year_list | awk '{print $2}')
		cat html/$1/top.html | sed 's|<!-- prev year !-->|'$prev_year'|g' > temp/top0
	fi

	next_year=$(grep "$(echo $year_n+1 | bc) " temp/year_list | awk '{print $2}')

	if [ -z $next_year ]; then
		cat temp/top0 | sed 's|^.*<!-- next year !-->.*$||' > temp/top1
	else
		cat temp/top0 | sed 's|<!-- next year !-->|'$next_year'|g' > temp/top1
	fi

	if [ $year_n = 1 ]; then
		cat temp/top1 | sed 's|<!-- nav class !-->|nav-right|' > temp/top2
	elif [ -z $next_year ]; then
		cat temp/top1 | sed 's|<!-- nav class !-->|nav-left|' > temp/top2
	else
		cat temp/top1 | sed 's|<!-- nav class !-->|nav-both|' > temp/top2
	fi

	cat temp/top2 | sed 's|<!-- year !-->|'$year'|' > temp/top3
	cat html/common/top-pre-css.html | sed 's|<!-- title !-->|'$year'|' > temp/top4
	cat temp/top4 html/$1/css.html html/common/top-post-css.html temp/top3 temp/years/$year html/common/back-to-top.html html/common/footer.html > site/$1/$year.html
done

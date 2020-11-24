#!/bin/sh

[ -d temp ] && rm -r temp
mkdir -p temp/years

year_n=0

for file in $(ls posts-md); do
	date=$(echo $file | sed 's|\.md||')
	year=$(echo $date | sed 's|-.*||')
	month=$(echo $date | sed 's|....-||; s|-..$||')
	month_word=$(grep $month months | awk '{print $2}')
	title=$(head -n 1 posts-md/$file | sed 's|# ||')
	

	if [ -z $prev_year ]; then
		year_n=$(echo "$year_n + 1" | bc)
		echo "$year_n $year" > temp/year_list

		echo "<h2>$month_word</h2>" > temp/years/$year
		echo "<ul>" >> temp/years/$year
		echo "<li><a href='../posts/$date.html'>$date – $title</a></li>" >> temp/years/$year

	elif [ $year = $prev_year ] && [ $month = $prev_month ]; then
		echo "<li><a href='../posts/$date.html'>$date – $title</a></li>" >> temp/years/$year

	elif [ $year = $prev_year ]; then
		echo "</ul>" >> temp/years/$year
		echo "<h2>$month_word</h2>" >> temp/years/$year
		echo "<ul>" >> temp/years/$year
		echo "<li><a href='../posts/$date.html'>$date – $title</a></li>" >> temp/years/$year
	else
		year_n=$(echo "$year_n + 1" | bc)
		echo "$year_n $year" >> temp/year_list

		echo "</ul>" >> temp/years/$prev_year
		echo "<h2>$month_word</h2>" > temp/years/$year
		echo "<ul>" >> temp/years/$year
		echo "<li><a href='../posts/$date.html'>$date – $title</a></li>" >> temp/years/$year
	fi

	prev_year=$year
	prev_month=$month
done

echo "</ul>" >> temp/years/$year

./finish-years.sh index

rm -r temp

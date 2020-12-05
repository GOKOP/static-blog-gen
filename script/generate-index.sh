#!/bin/sh

[ -d temp/years ] && rm -r temp/years
mkdir temp/years

year_n=0

for file in $(ls -r posts-md); do
	date=$(head -n1 temp/postdata/$file)
	year=$(echo $date | sed 's|-.*||')
	month=$(echo $date | sed 's|....-||; s|-..$||')
	month_word=$(grep $month months | awk '{print $2}')
	title=$(head -n 1 posts-md/$file | sed 's|# ||')
	html_file=$(echo $file | sed 's|\.md|.html|')

	if [ -z $prev_year ]; then
		year_n=$(echo "$year_n + 1" | bc)
		echo "$year_n $year" > temp/year_list

		echo "<h2>$month_word</h2>" > temp/years/$year
		echo "<ul>" >> temp/years/$year
		echo "<li><a href='../posts/$html_file'>$date – $title</a></li>" >> temp/years/$year

	elif [ $year = $prev_year ] && [ $month = $prev_month ]; then
		echo "<li><a href='../posts/$html_file'>$date – $title</a></li>" >> temp/years/$year

	elif [ $year = $prev_year ]; then
		echo "</ul>" >> temp/years/$year
		echo "<h2>$month_word</h2>" >> temp/years/$year
		echo "<ul>" >> temp/years/$year
		echo "<li><a href='../posts/$html_file'>$date – $title</a></li>" >> temp/years/$year
	else
		year_n=$(echo "$year_n + 1" | bc)
		echo "$year_n $year" >> temp/year_list

		echo "</ul>" >> temp/years/$prev_year
		echo "<h2>$month_word</h2>" > temp/years/$year
		echo "<ul>" >> temp/years/$year
		echo "<li><a href='../posts/$html_file'>$date – $title</a></li>" >> temp/years/$year
	fi

	prev_year=$year
	prev_month=$month
done

echo "</ul>" >> temp/years/$year

script/finish-years.sh index

rm -r temp

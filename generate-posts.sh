#!/bin/sh

[ -d posts ] && rm -r posts
mkdir posts

[ -d temp ] && rm -r temp
mkdir temp

for file in $(ls posts-md); do 
	pandoc posts-md/$file -f markdown -t html -o temp/post
	date=$(echo $file | sed 's|\.md||')
	year=$(echo $date | sed 's|-.*||')
	title="$(head -n 1 posts-md/$file | sed 's|# ||')"
	cat post-templ/top.html | sed 's|<!-- post title !-->|'"$title"'|; s|<!-- year !-->|'$year'|; s|<!-- date !-->|'$date'|' > temp/top
	cat temp/top temp/post post-templ/bottom.html > "posts/$date.html"
done

rm -r temp

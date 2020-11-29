#!/bin/sh

[ -d site/posts ] && rm -r site/posts
mkdir site/posts

[ -d temp ] && rm -r temp
mkdir temp

for file in $(ls posts-md); do 
	pandoc posts-md/$file -f markdown -t html -o temp/post
	date=$(echo $file | sed 's|_.*||; s|\.md||')
	year=$(echo $date | sed 's|-.*||')
	title="$(head -n 1 posts-md/$file | sed 's|# ||')"
	html_file=$(echo $file | sed 's|\.md|.html|')
	cat html/common/top-pre-css.html html/post/css.html html/common/top-post-css.html html/post/top.html > temp/top0
	sed 's|<!-- title !-->|'"$title"'|; s|<!-- year !-->|'"$year"'|; s|<!-- date !-->|'$date'|' temp/top0 > temp/top1
	cat temp/top1 temp/post html/common/back-to-top.html html/common/footer.html > "site/posts/$html_file"
done

rm -r temp

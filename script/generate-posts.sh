#!/bin/sh

[ -d site/posts ] && rm -r site/posts
mkdir -p site/posts

for file in $(ls posts-md); do 
	date=$(head -n1 temp/postdata/$file)
	[ $(wc -l < temp/postdata/$file) = 2 ] && edit_date=$(tail -n1 temp/postdata/$file)
	year=$(echo $date | sed 's|-.*||')
	title="$(head -n 1 posts-md/$file | sed 's|# ||')"
	html_file=$(echo $file | sed 's|\.md|.html|')
	cat html/common/top-pre-css.html html/post/css.html html/common/top-post-css.html html/post/top.html > temp/top0
	sed 's|<!-- title !-->|'"$title"'|; s|<!-- year !-->|'"$year"'|; s|<!-- date !-->|'$date'|' temp/top0 > temp/top1

	if [ -z $edit_date ]; then
		sed 's|.*<!-- edit date !-->.*||' temp/top1 > temp/top2
	else
		sed 's|<!-- edit date !-->|'$edit_date'|' temp/top1 > temp/top2
	fi

	cat temp/top2 temp/posts/$(echo $file | sed 's|.md|.html|') html/common/back-to-top.html html/common/footer.html > "site/posts/$html_file"
done

#!/bin/sh

[ ! -d temp/posts ] && mkdir -p temp/posts

for file in $(ls posts-md); do
	pandoc posts-md/$file -f markdown -t html -o temp/posts/$(echo $file | sed 's|.md$|.html|')
done

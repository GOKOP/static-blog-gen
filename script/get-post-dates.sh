#!/bin/sh

[ ! -d temp/postdata ] && mkdir -p temp/postdata

for file in $(ls posts-md); do
	date=$(echo $file | sed 's|_.*||; s|\.md||')
	echo $date > temp/postdata/$file
done

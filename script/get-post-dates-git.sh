#!/bin/sh

[ ! -d temp/postdata ] && mkdir -p temp/postdata

(
cd posts-md
for commit in $(git log --oneline --reverse | awk '{print $1}'); do
	date=$(git diff-tree --root --format=%cs $commit | head -n1)
	files="$(git diff-tree --root --no-commit-id --name-only $commit)"

	for file in $files; do
		if [ ! -f ../temp/postdata/$file ]; then
			echo $date > ../temp/postdata/$file
			echo "" >> ../temp/postdata/$file
		else
			sed '2s|.*|'$date'|' ../temp/postdata/$file > ../temp/$file
			mv ../temp/$file ../temp/postdata/$file
		fi
	done
done
)

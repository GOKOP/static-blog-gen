#!/bin/sh

get_post_dates() {
	[ -d temp/postdata ] && rm -r temp/postdata
	mkdir temp/postdata

	for file in $(ls posts-md); do
		date=$(echo $file | sed 's|_.*||; s|\.md||')
		echo $date > temp/postdata/$file
	done
}

get_post_dates_git() {
	[ -d temp/postdata ] && rm -r temp/postdata
	mkdir temp/postdata

	# subshell so as not to cd back
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
}

convert_posts() {
	[ -d temp/posts ] && rm -r temp/posts
	mkdir temp/posts

	for file in $(ls posts-md); do
		pandoc posts-md/$file -f markdown -t html -o temp/posts/$(echo $file | sed 's|.md$|.html|')
	done
}

generate_posts() {
	mkdir site/posts

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
	
		cat temp/top2 temp/posts/$html_file html/common/back-to-top.html html/common/footer.html > "site/posts/$html_file"
	done
}

finish_years() {
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
}

generate_roll() {
	[ -d temp/years ] && rm -r temp/years
	mkdir temp/years

	year_n=0
	
	for file in $(ls -r posts-md); do
		date=$(head -n1 temp/postdata/$file)
		[ $(wc -l < temp/postdata/$file) = 2 ] && edit_date=$(tail -n1 temp/postdata/$file)
		year=$(echo $date | sed 's|-.*||')
		html_file=$(echo $file | sed 's|\.md|.html|')
	
		if [ -z $prev_year ] || [ $year != $prev_year ]; then
			year_n=$(echo $year_n+1 | bc)
			echo "$year_n $year" >> temp/year_list
		fi
	
		sed 's|<!-- date !-->|'$date'|; s|<!-- post !-->|'$html_file'|' html/roll/post-head.html > temp/top
	
		if [ -z $edit_date ]; then
			sed 's|.*<!-- edit date !-->.*||' temp/top >> temp/years/$year
		else
			sed 's|<!-- edit date !-->|'$edit_date'|' temp/top >> temp/years/$year
		fi
	
		cat temp/posts/$html_file html/common/back-to-top.html >> temp/years/$year
		
		prev_year=$year
	done
	
	finish_years roll
}

generate_index() {
	[ -d temp/years ] && rm -r temp/years
	mkdir temp/years

	year_n=0
	prev_year=-1
	
	for file in $(ls -r posts-md); do
		date=$(head -n1 temp/postdata/$file)
		year=$(echo $date | sed 's|-.*||')
		month=$(echo $date | sed 's|....-||; s|-..$||')
		month_word=$(grep $month months | awk '{print $2}')
		title=$(head -n 1 posts-md/$file | sed 's|# ||')
		html_file=$(echo $file | sed 's|\.md|.html|')
	
		if [ $prev_year = -1 ]; then
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
	
	finish_years index
}

generate_site_index() {
	pandoc index.md -f markdown -t html -o temp/index
	sed 's|<!-- title !-->|Main page|' html/common/top-pre-css.html > temp/top0
	cat temp/top0 html/site-index/css.html html/common/top-post-css.html temp/index html/common/footer.html > site/index.html
}


# -------------------- end of function declarations --------------------


# check if there's anything to generate
posts="$(ls posts-md)"
[ -z "$posts" ] && echo "Write some posts first!" && exit

[ -d site ] && rm -r site
mkdir site

[ -d temp ] && rm -r temp
mkdir temp

# is posts-md its own git repo?
dir="$(pwd)"
cd posts-md
toplevel="$(git rev-parse --show-toplevel 2>/dev/null)"
excode=$?
cd "$dir"
[ $excode != 0 ] && get_post_dates || \
[ "$toplevel" != "$dir/posts-md" ] && get_post_dates || \
get_post_dates_git

convert_posts
generate_posts
generate_roll
generate_index
generate_site_index

cp -r css site/

last_year=$(ls site/index | tail -n 1)
ln -s $last_year site/index/index.html
ln -s $last_year site/roll/index.html

rm -r temp

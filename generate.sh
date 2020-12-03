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
[ $excode != 0 ] && script/get-post-dates.sh || \
[ "$toplevel" != "$dir/posts-md" ] && script/get-post-dates.sh || \
script/get-post-dates-git.sh

script/convert-posts.sh
script/generate-posts.sh
script/generate-roll.sh
script/generate-index.sh
script/generate-site-index.sh

cp -r css site/

last_year=$(ls site/index | tail -n 1)
ln -s $last_year site/index/index.html
ln -s $last_year site/roll/index.html

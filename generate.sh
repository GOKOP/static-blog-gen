# check if there's anything to generate
posts="$(ls posts-md)"
[ -z "$posts" ] && echo "Write some posts first!" && exit

[ -d site ] && rm -r site
mkdir site

[ -d temp ] && rm -r temp
mkdir temp

script/convert-posts.sh
script/generate-posts.sh
script/generate-roll.sh
script/generate-index.sh
script/generate-site-index.sh

cp -r css site/

last_year=$(ls site/index | tail -n 1)
ln -s $last_year site/index/index.html
ln -s $last_year site/roll/index.html

[ -d site ] && rm -r site
mkdir site

script/generate-posts.sh
script/generate-index.sh
script/generate-roll.sh
script/generate-site-index.sh

cp -r css site/

last_year=$(ls site/index | tail -n 1)
ln -s $last_year site/index/index.html
ln -s $last_year site/roll/index.html

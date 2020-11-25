[ -d site ] && rm -r site
mkdir site

script/generate-posts.sh
script/generate-index.sh
script/generate-roll.sh

cp -r css site/

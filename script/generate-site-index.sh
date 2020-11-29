#!/bin/sh

[ -d temp ] && rm -r temp
mkdir temp

pandoc index.md -f markdown -t html -o temp/index
sed 's|<!-- title !-->|Main page|' html/common/top-pre-css.html > temp/top0
cat temp/top0 html/site-index/css.html html/common/top-post-css.html temp/index html/common/footer.html > site/index.html

rm -r temp

#!/bin/bash
set -eu

if [ ! -d doc/build ]; then
    echo 'Error: invalid directory. Deploy from repo root.'
    exit 1
fi

[ "$GH_PASSWORD" ] || exit 12

sitemap() {
    WEBSITE='https://pdoc3.github.io/pdoc'
    find -name '*.html' |
        sed "s,^\.,$WEBSITE," |
        sed 's/index.html$//' |
        grep -v '/google.*\.html$' |
        sort -u  > 'sitemap.txt'
    echo "Sitemap: $WEBSITE/sitemap.txt" > 'robots.txt'
}

head=$(git rev-parse HEAD)

git clone -b gh-pages "https://kernc:$GH_PASSWORD@github.com/$TRAVIS_REPO_SLUG.git" gh-pages
mkdir -p gh-pages/doc
cp -R doc/build/* gh-pages/doc/
cd gh-pages
sitemap
git add *
git diff --staged --quiet && echo "$0: No changes to commit." && exit 0
git commit -a -m "CI: Update docs for $TRAVIS_TAG ($head)"
git push

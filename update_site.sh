#! /bin/bash

if [ -d "/tmp/versi786.github.io" ]; then
  echo "Error: /tmp/versi786.github.io already exists"
  exit 1
fi

cp ./lc5/lc5.html /tmp
cd /tmp
git clone git@github.com:versi786/versi786.github.io.git

cp ./lc5.html ./versi786.github.io/
cd ./versi786.github.io

git add lc5.html
git commit -m 'update lc5.html'
git push origin master

cd ..
rm -rf versi786.github.io
rm -f lc5.html

echo "Please navigate to www.aasifversi.com/lc5.html"

#!/usr/local/bin/zsh
if [ ! $1 ]
then
echo "I need a post name dude"
exit 1
fi

POST_NAME=$1
DATE=`date +%Y-%m-%d`
TIME="09:00:00 -04:00"

FILE=./_posts/$DATE"-"$POST_NAME".md"

if [ ! -e "$FILE" ]
then
cat > $FILE << EOM
---
layout: post
title:
date: ${DATE} 09:00:00 -04:00
categories: post
desc:
permalink: /:categories/:year/:month/:day/:title/
---
EOM
else
echo "File already exists"
fi

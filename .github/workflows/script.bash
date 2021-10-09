#!/bin/bash

function get_url () {
    echo "https://marimelon.github.io/${1#./}" | sed -e 's/.md//g'
}

for file in `\find . -name '*.md'`; do
    HEAD_LINE_NUM=$(sed -n '/^# /=' $file | head -n 1 -)
    HEAD_LINE=$(sed -n ${HEAD_LINE_NUM}p $file)
    if [[ ! $HEAD_LINE =~ "http" ]]; then
      URL=`get_url $file`
      echo $URL
      sed -i -e "$HEAD_LINE_NUM s/^# \([^\r\n]*\).*/# \[\1\](${URL//\//\\\/})/g" $file
    fi
done
# Marimelonのメモ帳

## 一覧

% function get_title () {
%     pandoc -f markdown -t json $1 \
%     | jq -r '.blocks | map(select(.t == "Header")) | .[0] | recurse | select(.t? == "Str") | .c'
% }

% for d in ./note/*/ ; do
    % DIR_NAME=$(basename $d)
    <details open>
    <summary><% $DIR_NAME %></summary>

    % for f in `\find ./note/$DIR_NAME -name '*.md' | sort` ; do
        - [<%% get_title $f %>](<% $f %>)
    % done
    
    </details>
% done
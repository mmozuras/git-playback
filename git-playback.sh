#!/bin/bash

set -e

if [ $# -eq 0 ]; then
  set -- -h
fi

OPTS_SPEC="\
git playback file1 file2 ...
--
h,help        show the help
s,start=      specify start revision. Default: root commit
e,end=        specify end revision. Default: current branch
t,style=      specify style to be used in output
l,stylelist   list all available styles
"
eval "$(echo "$OPTS_SPEC" | git rev-parse --parseopt -- "$@" || echo exit $?)"

get_git_branch() {
  git branch 2>/dev/null | grep -e ^* | tr -d \*
}

get_root_commit() {
  git rev-list --max-parents=0 HEAD 2>/dev/null | tr -d \*
}

files=()
output_file='playback.html'
start_revision=`get_root_commit`
end_revision=`get_git_branch`
style='default'
available_styles=(default dark far idea sunburst zenburn vs ascetic magula github googlecode brown_paper school_book ir_black solarized_dark solarized_light arta monokai xcode pojoaque)

while [ $# -gt 0 ]; do
  opt="$1"
  shift
  case "$opt" in
    -s) start_revision="$1"; shift;;
    -e) end_revision="$1"; shift;;
    -t) style="$1"; shift;;
    -l) echo ${available_styles[@]}; exit;;
    *) files+=("$1") ;;
  esac
done

is_style_available() {
  for i in ${available_styles[@]}; do
    if [ $i == $1 ]; then
      return 1
    fi
  done
  return 0
}

if is_style_available $style; then
  echo "Style is not available: ${style}. You can list available styles with --stylelist."
  exit 1
fi

source_file="${BASH_SOURCE[0]}"
while [ -h "$source_file" ]; do
  source_file="$(readlink "$source_file")";
done
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd -P "$(dirname "$source_file")" && pwd)"
unset source_file

js=`cat ${script_dir}/playback.js`
css=`cat ${script_dir}/playback.css`
htmlStart="<!DOCTYPE html>
<html lang='en'>
<head>
    <meta charset='utf-8'>
    <title>Git Playback</title>

    <style type='text/css'>${css}</style>
    <link rel='stylesheet' href='http://yandex.st/highlightjs/7.0/styles/${style}.min.css' type='text/css'>
</head>
<body>
    <div id='playback'>
        <div class='container'>"

htmlEnd="</div>
    </div>

    <script src='https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js'></script>
    <script src='http://yandex.st/highlightjs/7.0/highlight.min.js'></script>
    <script type='text/javascript'>${js}</script>
    <script>
      jQuery(document).ready(function(){
          jQuery('#playback').playback();
          hljs.initHighlightingOnLoad();

          var background = jQuery('pre code').css('background-color');
          jQuery('body').css('background-color', background);
      });
    </script>
</body>
</html>"


foreach_git_revision() {
  command=$1

  revisions=`git rev-list --reverse ${end_revision} ^${start_revision}`

  for revision in $revisions; do
      git checkout --quiet $revision
      eval $command
      git reset --hard
  done

  git checkout --quiet $end_revision
}

output_to_file() {
  no_files=true
  for file in ${files[@]}
  do
    if [ -f $file ] && [ -s $file ]; then
      no_files=false
    fi
  done

  if ! $no_files; then
    echo '<div class="playback"><ul>' >> $output_file
    for file in ${files[@]}
    do
      echo -e '<li><pre><code>\c' >> $output_file
      if [ -f $file ]; then
        eval "$(git diff --unified=999999 HEAD~1 $file | read_diff >> $output_file)"
      fi
      echo -e '</code></pre></li>\c' >> $output_file
    done
    echo '</ul></div>' >> $output_file
  fi
}

read_diff() {
  OIFS=$IFS
  IFS=''

  read -r s

  while [[ $? -eq 0 ]]
  do
    if [[ $s == diff*  ]] ||
       [[ $s == +++*   ]] ||
       [[ $s == ---*   ]] ||
       [[ $s == @@*    ]] ||
       [[ $s == index* ]]; then
      cls='none'
    elif [[ $s == +*   ]]; then
      s=$(sed 's/^\s*./ /g' <<<"$s")
      cls='new'
    elif [[ $s == -*    ]]; then
      s=$(sed 's/^\s*./ /g' <<<"$s")
      cls='old'
    else
      cls=
    fi

    if [[ "$cls" == 'none' ]]; then
      cls='none'
    elif [[ "$cls" ]]; then
      echo -e '<div class="'${cls}'">'${s}'</div>\c'
    else
      echo -e '<div>'${s}'</div>\c'
    fi
    read -r s
  done

  IFS=$OIFS
}

rm -f $output_file
echo $htmlStart >> $output_file
foreach_git_revision output_to_file
echo $htmlEnd >> $output_file

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
available_styles=(default dark far idea sunburst zenburn vs ascetic magula github googlecode brown_paper school_book ir_black solarized_dark solarized_light arta monokai xcode pojoaque tomorrow tomorrow-night tomorrow-night-blue tomorrow-night-eighties tomorrow-night-bright)

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

js=`cat ${script_dir}/git-playback.js/playback.js`
jquery=`cat ${script_dir}/git-playback.js/jquery.js`
highlight=`cat ${script_dir}/git-playback.js/highlight.js`
css=`cat ${script_dir}/git-playback.css/playback.css`
stylecss=`cat ${script_dir}/git-playback.css/${style}.css`
htmlStart="<!DOCTYPE html>
<html lang='en'>
<head>
    <meta charset='utf-8'>
    <title>Git Playback</title>

    <style type='text/css'>${css}</style>
    <style type='text/css'>${stylecss}</style>
</head>
<body>
    <div id='playback'>
        <div class='container'>"

htmlEnd="</div>
    </div>

    <script type='text/javascript'>${jquery}</script>
    <script type='text/javascript'>${highlight}</script>
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

has_files() {
  for file in ${files[@]}
  do
    if [ -f $file ] && [ -s $file ]; then
      return 0
    else
      return 1
    fi
  done
}

write_playback_opening_tag() {
  echo '<div class="playback"><ul>' >> $output_file
}

write_playback_closing_tag() {
  echo '</ul></div>' >> $output_file
}

write_code_opening_tag() {
  echo -e '<li><pre><code>\c' >> $output_file
}

write_code_closing_tag() {
  echo -e '</code></pre></li>\c' >> $output_file
}

write_file() {
  if [ -f $1 ]; then
    eval "$(cat $1 >> $output_file)"
  fi
}

write_diff() {
  if [ -f $1 ]; then
    line_count="$(git diff --unified=999999 HEAD~1 $1 | grep '[^ ]' | wc -l)"
    if [ $line_count -eq 0 ]; then
      eval "$(cat $1 >> $output_file)"
    else
      eval "$(git diff --unified=999999 HEAD~1 $1 | read_diff >> $output_file)"
    fi
  fi
}

write_start_revision() {
  git checkout --quiet $start_revision

  if has_files; then
    write_playback_opening_tag
    for file in ${files[@]}
    do
      write_code_opening_tag
      write_file $file
      write_code_closing_tag
    done
    write_playback_closing_tag
  fi

  git reset --hard
}

write_revision() {
  if has_files; then
    write_playback_opening_tag
    for file in ${files[@]}
    do
      write_code_opening_tag
      write_diff $file
      write_code_closing_tag
    done
    write_playback_closing_tag
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
      class='none'
    elif [[ $s == +*   ]]; then
      s=${s#+}
      class='new'
    elif [[ $s == -*   ]]; then
      s=${s#-}
      class='old'
    else
      s=${s# }
      class=
    fi

    if [[ "$class" == 'none' ]]; then
      class='none'
    elif [[ "$class" ]]; then
      echo -E '<div class="'${class}'">'${s}
      echo -e '</div>\c'
    else
      echo -E $s
    fi
    read -r s
  done

  IFS=$OIFS
}

rm -f $output_file
echo $htmlStart >> $output_file
write_start_revision
foreach_git_revision write_revision
echo $htmlEnd >> $output_file

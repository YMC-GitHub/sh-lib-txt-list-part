#!/bin/sh

[ -z "$THIS_FILE_PATH" ] && THIS_FILE_PATH=$(cd $(dirname $0);pwd)
[ -z "$THIS_FILE_NAME" ] && THIS_FILE_NAME=$(basename $0)
[ -z "$RUN_SCRIPT_PATH" ] && RUN_SCRIPT_PATH="$THIS_FILE_PATH"


###
# deps
###
#source "$THIS_FILE_PATH/sh-lib-path-resolve.sh"
# -[x] this_file_path_get

###
# apis
###
function this_file_name_get(){
  local res=
  res=$(basename $0)
  #THIS_FILE_NAME="$res"
  echo "$res"
}
# fun usage
# this_file_name_get
# THIS_FILE_NAME=$(this_file_name_get)

function this_file_path_get(){
  local p=
  local toDel=
  local res=
  res=$(cd $(dirname $0);pwd)
  # relative to THIS_FILE_PATH
  # [ $# -eq 1 ] && res=$(cd "$1/$2";pwd)
  # [ $# -eq 1 ] && { p="$res/$1";mkdir -p "$p" ; res=$(cd "$p";pwd);}
  #[ $# -eq 1 ] && { p="$res/$1";[ -e "$p" ] && res=$(cd "$p";pwd);}
  [ $# -eq 1 ] && { p="$res/$1"; [ ! -e "$p" ] && toDel="true" ; mkdir -p "$p"; res=$(cd "$p";pwd); [ "$toDel" = "true" ] && rm -rf "$p" ;}

  # relative to some path eg:PROJECT_PATH
  #[ $# -eq 2 ] && res=$(cd "$1/$2";pwd)
  #[ $# -eq 2 ] && res=$(cd "$2/$1";pwd)
  #[ $# -eq 2 ] && { p="$1/$2"; [ -e "$p" ] && res=$(cd "$p";pwd);}
  [ $# -eq 2 ] && { p="$1/$2"; [ ! -e "$p" ] && toDel="true" ; mkdir -p "$p"; res=$(cd "$p";pwd); [ "$toDel" = "true" ] && rm -rf "$p" ;}
  echo "$res"
}
# fun usage
# this_file_path_get
# THIS_FILE_PATH=$(this_file_path_get)
# this_file_path_get "../"
# PROJECT_PATH=$(this_file_path_get "../")


function project_path_get(){
  local p=
  local toDel=
  local res=
  local to=
  local _THIS_FILE_PATH=
  [ -n "$1" ] && to="$1"; [ -z "$to" ] && to="../";
  # get this file path
  # get project path
  [ -z "$PROJECT_PATH" ] && { p="$1"; toDel=; _THIS_FILE_PATH=$(cd $(dirname $0);pwd); p="$_THIS_FILE_PATH/$p"; [ ! -e "$p" ] && toDel="true" ; mkdir -p "$p"; PROJECT_PATH=$(cd "$p";pwd); [ "$toDel" = "true" ] && rm -rf "$p" ; }
  res="$PROJECT_PATH"

  # relative to PROJECT_PATH
  local list=
  local item=
  local p_list=
  # update $@:delete the first  var in $@
  shift ;
  p_list="$@"
  for item in $(echo "$p_list")
  do
    list="$list/$item"
  done
  list=$(echo "$list" | sed "s/^\///g")
  [ $# -gt 0 ] && res="$PROJECT_PATH/$list"
  echo "$res"
}
# fun usage
# project_path_get
# project_path_get "../"
# project_path_get "../" "src"
# project_path_get "../" "test" "unit"
# echo "$PROJECT_PATH"

function project_dir_map_gen(){
  local p=
  local b=
  [ "${1}" ] && b="${1}"
  [ -z "$b" ] && b="$THIS_FILE_PATH"
  [ -z "$b" ] && b=$(this_file_path_get)

  [ "${2}" ] && p="${2}"
  [ -z "$p" ] && p="../"

  PROJECT_PATH=$(this_file_path_get "$b" "$p")
  BUILD_PATH=$(this_file_path_get "$PROJECT_PATH" "build")
  PACKAGE_PATH=$(this_file_path_get "$PROJECT_PATH" "packages")
  HELP_PATH=$(this_file_path_get $PROJECT_PATH "help")
  SRC_PATH=$(this_file_path_get $PROJECT_PATH "src")
  TEST_PATH=$(this_file_path_get $PROJECT_PATH "test")
  DIST_PATH=$(this_file_path_get $PROJECT_PATH "dist")
  LIB_PATH=$(this_file_path_get $PROJECT_PATH "lib")
  DOCS_PATH=$(this_file_path_get $PROJECT_PATH "docs")
  NOTE_PATH=$(this_file_path_get "$PROJECT_PATH" "note")
  TOOL_PATH=$(this_file_path_get $PROJECT_PATH "tool")
  SAMPLE_PATH=$(this_file_path_get $PROJECT_PATH "sample")
}
# fun usage
# project_dir_map_gen
# project_dir_map_gen "$THIS_FILE_PATH" "../"

function project_dir_map_gen2(){
  local p=
  [ "${1}" ] && p="${1}" ; [ -z "$p" ] && p="../"

  PROJECT_PATH=$(project_path_get "$p")
  BUILD_PATH=$(project_path_get "$PROJECT_PATH" "build")
  PACKAGE_PATH=$(project_path_get "$PROJECT_PATH" "packages")
  HELP_PATH=$(project_path_get $PROJECT_PATH "help")
  SRC_PATH=$(project_path_get $PROJECT_PATH "src")
  TEST_PATH=$(project_path_get $PROJECT_PATH "test")
  DIST_PATH=$(project_path_get $PROJECT_PATH "dist")
  LIB_PATH=$(project_path_get $PROJECT_PATH "lib")
  DOCS_PATH=$(project_path_get $PROJECT_PATH "docs")
  NOTE_PATH=$(project_path_get "$PROJECT_PATH" "note")
  TOOL_PATH=$(project_path_get $PROJECT_PATH "tool")
  SAMPLE_PATH=$(this_file_path_get $PROJECT_PATH "sample")
}
# fun usage
# project_dir_map_gen2
# project_dir_map_gen2 "../"

function project_dir_map_tpl(){
  local l= ; [ "${1}" ] && l="${1}" ;
  [ -z "$l" ] && l=$(cat<<EOF
# sample
BUILD_PATH:build
PACKAGE_PATH:package
HELP_PATH:help
SRC_PATH:src
TEST_PATH:test
DIST_PATH:dist
LIB_PATH:lib
DOCS_PATH:docs
NOTE_PATH:note
TOOL_PATH:tool
EOF
)
  l=$(echo "$l" | sed "s,^ *#.*,,g" | sed "/^ *$/d")
  echo "$l" | while read line
  do
      key=$(echo "$line" | cut -d ":" -f 1)
      val=$(echo "$line" | cut -d ":" -f 2)
      echo "$key=\$(project_path_get \"\$PROJECT_PATH\" \"$val\")"
  done
}
# fun usage
# project_dir_map_tpl
# project_dir_map_tpl "$tpl"


function project_dir_map_gen3(){
  local p=
  [ "${1}" ] && p="${1}" ; [ -z "$p" ] && p="../"
  [ "${2}" ] && dir_map_tpl="${2}" ;
  sh_code=$(project_dir_map_tpl "$dir_map_tpl")
  PROJECT_PATH=$(project_path_get "$p")
  #echo "$sh_code" ; eval $sh_code ; echo "$D"
  #echo "$sh_code" ; eval $sh_code ; echo "$TOOL_PATH"

  eval $sh_code ;

}
# fun usage
# project_dir_map_gen3
# project_dir_map_gen3 "../"

function project_dir_map_out(){
  local res=
  res=$(cat <<EOF
PROJECT_PATH:$PROJECT_PATH
BUILD_PATH:$BUILD_PATH
PACKAGE_PATH:$PACKAGE_PATH
HELP_PATH:$HELP_PATH
SRC_PATH:$SRC_PATH
TEST_PATH:$TEST_PATH
DIST_PATH:$DIST_PATH
DIST_PATH:$DIST_PATH
LIB_PATH:$LIB_PATH
DOCS_PATH:$DOCS_PATH
NOTE_PATH:$NOTE_PATH
TOOL_PATH:$TOOL_PATH
EOF
)
  echo "$res"
}
# fun usage
# project_dir_map_out



function project_dir_out_tpl(){
  local l= ; [ "${1}" ] && l="${1}" ;
  [ -z "$l" ] && l=$(cat<<EOF
# sample
BUILD_PATH:build
PACKAGE_PATH:package
HELP_PATH:help
SRC_PATH:src
TEST_PATH:test
DIST_PATH:dist
LIB_PATH:lib
DOCS_PATH:docs
NOTE_PATH:note
TOOL_PATH:tool
EOF
)
  l=$(echo "$l" | sed "s,^ *#.*,,g" | sed "/^ *$/d")
  echo "$l" | while read line
  do
      key=$(echo "$line" | cut -d ":" -f 1)
      eval "echo $key=\$$key"
  done
}
# fun usage
# project_dir_out_tpl
# project_dir_out_tpl "$tpl"


function project_dir_map_out3(){
  local p=
  [ "${1}" ] && p="${1}" ; [ -z "$p" ] && p="../"
  [ "${2}" ] && dir_map_tpl="${2}" ;
  sh_code=$(project_dir_out_tpl "$dir_map_tpl")
  PROJECT_PATH=$(project_path_get "$p")
  #echo "$sh_code" ; eval $sh_code ; echo "$D"
  #echo "$sh_code" ; eval $sh_code ; echo "$TOOL_PATH"

  echo "$sh_code" ;

}
# fun usage
# project_dir_map_out3
# project_dir_map_out3 "../"

###
# sample
###
#[ -z "$THIS_FILE_PATH" ] && THIS_FILE_PATH=$(this_file_path_get) ; project_dir_map_gen2 "../"

#project_dir_map_out
# file usage
# test/sh-lib-project-dir-map.sh
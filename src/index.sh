#!/bin/sh

###
# deps
###

###
# apis
###
function txt_list_part_get(){
  local s=
  local e=
  local t=
  [ "${1}" ] && t="${1}"
  [ -z "$t" ] && t=""
  [ "${2}" ] && s="${2}"
  [ -z "$s" ] && s="\[master\]"
  [ "${3}" ] && e="${3}"
  [ -z "$e" ] && e="^$"
  #echo "$t" | sed  -n "/$s/,/$e/p" | sed "/$s/d" | sed "/$e/d" #| sed "/^$/d"
  #or:
  echo "$t" | sed  -n "/$s/,/$e/{/$s/!{/$e/!p}}"
}
# fun usage
#txt_list_part_get "$txt"
#txt_list_part_get "$txt" "\[master\]" "^$"

function txt_list_part_get2(){
  local s=
  local e=
  local t=
  [ "${1}" ] && t="${1}"
  [ -z "$t" ] && t=""
  [ "${2}" ] && s="${2}"
  [ -z "$s" ] && s="\[master\]"
  [ "${3}" ] && e="${3}"
  [ -z "$e" ] && e="^$"
  # get json arr
  t=$(echo "$t" | sed  -n "/$s/,/$e/p")
  # delete s str
  #t=$(echo "$t" |sed "/$s/d")
  # delete e str
  #t=$(echo "$t" |sed "/$e/d")
  echo "$t"
}
# fun usage
#txt_list_part_get2 "$txt"
#txt_list_part_get2 "$txt" "\[master\]" "^$"


function txt_list_part_del2(){
  local s=
  local e=
  local t=
  [ "${1}" ] && t="${1}"
  [ -z "$t" ] && t=""
  [ "${2}" ] && s="${2}"
  [ -z "$s" ] && s="\[master\]"
  [ "${3}" ] && e="${3}"
  [ -z "$e" ] && e="^$"
  # get json arr
  echo "$t" | sed  -n "/$s/,/$e/d"
}
# fun usage
#txt_list_part_del2 "$txt"
#txt_list_part_del2 "$txt" "\[master\]" "^$"


function txt_list_part_add3(){
  local part= ; [ "${1}" ] && part="${1}" ; [ -z "$part" ] && part="" ;
  local list= ; [ "${2}" ] && list="${2}" ; [ -z "$list" ] && list="$txt_list" ;
  [ "${part}" ] && txt_list=$(cat<<EOF
$txt_list
$part
EOF
)
  # out list
   echo "$txt_list"
}
# fun usage
# txt_list_part_add3
# txt_list_part_add3 "$part" "$txt_list"

function txt_list_part_del3(){
  local part= ; [ "${1}" ] && part="${1}" ; [ -z "$part" ] && part="" ;
  local list= ; [ "${2}" ] && list="${2}" ; [ -z "$list" ] && list="$txt_list" ;

  local s= ; s=$(echo "$part"|sed -n "1p");
  local e= ; e=$(echo "$part"|sed -n '$p');

  local res= ;
  res=$(echo "$list" | sed "/$s/,/$e/d")
  # update some relative var
  txt_list="$res"
  # out list
  echo "$res"
}
# fun usage
# txt_list_part_del3 "$part"
# txt_list_part_del3 "$part" "$txt_list"

function txt_list_part_get3(){
  local part= ; [ "${1}" ] && part="${1}" ; [ -z "$part" ] && part="" ;
  local list= ; [ "${2}" ] && list="${2}" ; [ -z "$list" ] && list="$txt_list" ;

  local s= ; s=$(echo "$part"|sed -n "1p");
  local e= ; e=$(echo "$part"|sed -n '$p');

  local res= ;
  res=$(echo "$list" | sed  -n "/$s/,/$e/p")
  # delete s str
  #res=$(echo "$res" |sed "/$s/d")
  # delete e str
  #res=$(echo "$res" |sed "/$e/d")

  # out list
  echo "$res"
}
# fun usage
# txt_list_part_get3 "$part"
# txt_list_part_get3 "$part" "$txt_list"


var_list=$(cat<<EOF
$var_list
txt_list=
EOF
)
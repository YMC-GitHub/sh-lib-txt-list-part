#!/bin/sh

###
# deps
###

###
# apis
###
function gpg_id_get_by_name_and_mail(){
  echo "# 用户编号-获取"
  local name= ; [ "${1}" ] && name="${1}" ; [ -z "$name" ] && name="yemiancheng" ;
  local mail= ; [ "${2}" ] && mail="${2}" ; [ -z "$mail" ] && mail="hualei03042013@163.com" ;
  local uid= ; uid="$name <$mail>"
  # step-x: list key and get the line before match pattern
  #[ "$uid" ] && gpg --list-keys | grep -B 1 "$uid" | grep -v "$uid" | sed "s/ //g"

  [ "$uid" ] &&  {
    GPG_USER_ID=$(gpg --list-keys | grep -B 1 "$uid" | grep -v "$uid" | sed "s/ //g" | sed "/^-*$/d") ;
    echo "$GPG_USER_ID" ;
  }
}
# fun usage
# gpg_id_get_by_name_and_mail
# gpg_id_get_by_name_and_mail "yemiancheng" "hualei03042013@163.com"
# gpg_id_get_by_name_and_mail "$GPG_USER_NAME" "$GPG_USER_EMAIL"

function gpg_id_list_by_mail(){
  echo "# 用户编号-获取"
  local mail= ; [ "${1}" ] && mail="${1}" ; [ -z "$mail" ] && mail="hualei03042013@163.com" ;
  local uid= ; uid="<$mail>"
  [ "$uid" ] &&  {
    #gpg --list-keys | grep -B 1 "$uid"
    #gpg --list-keys | grep -B 1 "$uid" | grep -v "$uid"
    gpg --list-keys | grep -B 1 "$uid" | grep -v "$uid" | sed "s/ //g" | sed "/^-*$/d" ;
  }
}
# fun usage
# gpg_id_list_by_mail
# gpg_id_list_by_mail "hualei03042013@163.com"
# gpg_id_list_by_mail "$GPG_USER_EMAIL"

function gpg_sec_key_list(){
  echo "# 列出目录"
  ls "$GPG_KEY_PATH"
  echo "# 列出密钥"
  gpg --list-keys
}
# fun usage
#gpg_sec_key_list


function gpg_sec_key_gen_v1(){
  echo "# 生成密钥"
  gpg --gen-key
}
# fun usage
#gpg_sec_key_gen_v1

function gpg_sec_key_gen_v2(){
  echo "# 生成密钥"
  gpg --full-generate-key
}
# fun usage
#gpg_sec_key_gen_v2


function gpg_cnf_key_tpl_01(){
  local tpl=$(
  cat <<EOF
%echo Generating a basic OpenPGP key
Key-Type: $GPG_KEY_TYPE
Key-Length: $GPG_KEY_LENGTH
Subkey-Type: ELG-E
Subkey-Length: 1024
Name-Real: $GPG_USER_NAME
Name-Comment: $GPG_USER_NOTE
Name-Email: $GPG_USER_EMAIL
Expire-Date: 0
Passphrase: abc
%pubring $FILE.pub
%secring $FILE.sec
# Do a commit here, so that we can later print "done" :-)
%commit
%echo done
EOF
)
  echo "$tpl"
}
# fun usage
# gpg_cnf_key_tpl_01
# gpg_cnf_key_tpl_01 > "$f"
# gpg_cnf_key_tpl_01 > "$GPG_CNF_KEY_FILE"

function gpg_cnf_key_tpl_02(){
  local tpl=$(
  cat <<EOF
%echo Generating a basic OpenPGP key
Key-Type: $GPG_KEY_TYPE
Key-Length: $GPG_KEY_LENGTH
Subkey-Type: $GPG_KEY_TYPE
Subkey-Length: $GPG_KEY_LENGTH
Name-Real: $GPG_USER_NAME
Name-Email: $GPG_USER_EMAIL
Expire-Date: $GPG_KEY_EXP
Passphrase: $GPG_PASSPHRASE
# Do a commit here, so that we can later print "done" :-)
%commit
%echo done
EOF
)
  echo "$tpl"
}
# fun usage
# gpg_cnf_key_tpl_02
# gpg_cnf_key_tpl_02 > "$f"
# gpg_cnf_key_tpl_02 > "$GPG_CNF_KEY_FILE"

function gpg_sec_key_gen(){
  local f= ; [ "${1}" ] && f="${1}" ; [ -z "$f" ] && f="$GPG_CNF_KEY_FILE" ; [ -z "$f" ] && f="" ;
  local p= ; [ "${2}" ] && p="${2}" ; [ -z "$p" ] && p="$GPG_PASSPHRASE" ; [ -z "$p" ] && p="yemiancheng123" ;
  [ "$f" ] && GPG_CNF_KEY_FILE="$f"
  [ "$p" ] && GPG_PASSPHRASE="$p"
  echo "# 生成密钥"
  # step-x: get cnf
  # step-x: get arg
  [ ! -e "$f" ] && {
    cat >"$f" <<EOF
%echo Generating a basic OpenPGP key
Key-Type: $GPG_KEY_TYPE
Key-Length: $GPG_KEY_LENGTH
Subkey-Type: $GPG_KEY_TYPE
Subkey-Length: $GPG_KEY_LENGTH
Name-Real: $GPG_USER_NAME
Name-Email: $GPG_USER_EMAIL
Expire-Date: $GPG_KEY_EXP
Passphrase: $GPG_PASSPHRASE
# Do a commit here, so that we can later print "done" :-)
%commit
%echo done
EOF
    gpg --batch --gen-key "$f"
  }
  GPG_PASSPHRASE=

}
# fun usage
#gpg_sec_key_gen
#gpg_sec_key_gen "$GPG_CNF_KEY_FILE" $GPG_PASSPHRASE

function gpg_sec_key_del(){
  echo "# 删除密钥"
  local id= ; [ "${1}" ] && id="${1}" ; [ -z "$id" ] && id="$GPG_USER_ID" ; [ -z "$id" ] && id="" ;
  [ "$id" ] && GPG_USER_ID="$id"
  gpg --delete-secret-key "$id"
  gpg --delete-key "$id"
}
# fun usage
#gpg_sec_key_del
#gpg_sec_key_del "$GPG_USER_ID"

function gpg_sec_key_del_by_mail(){
  echo "# 删除密钥"
  local mail= ; [ "${1}" ] && mail="${1}" ; [ -z "$mail" ] && mail="" ;
  local list=
  list=$(gpg_id_list_by_mail "$mail")
  list=$(echo "$list" | sed "/^ *#.*/d")
  #for line in $(echo "$list") ; do echo "gpg_sec_key_del $line"; done
  for line in $(echo "$list") ; do gpg_sec_key_del "$line"; done
}
# fun usage
#gpg_sec_key_del_by_mail
#gpg_sec_key_del_by_mail "$GPG_USER_MAIL"

function gpg_pri_key_list(){
  echo "# 列出私钥"
  gpg --list-secret-key
}
# fun usage
#gpg_pri_key_list

function gpg_pri_key_del(){
  echo "# 删除私钥"
  local id= ; [ "${1}" ] && id="${1}" ; [ -z "$id" ] && id="$GPG_USER_ID" ; [ -z "$id" ] && id="" ;
  [ "$id" ] && GPG_USER_ID="$id"
  gpg --delete-secret-key "$id"
}
# fun usage
#gpg_pri_key_del
#gpg_pri_key_del "$GPG_USER_ID"

function gpg_pri_key_export(){
  echo "# 导出私钥"
  local id= ; [ "${1}" ] && id="${1}" ; [ -z "$id" ] && id="$GPG_USER_ID" ; [ -z "$id" ] && id="" ;
  [ "$id" ] && GPG_USER_ID="$id"

  local f= ; [ "${2}" ] && f="${2}" ; [ -z "$f" ] && f="$GPG_PRI_KEY_FILE" ; [ -z "$f" ] && f="" ;
  [ "$f" ] && GPG_PRI_KEY_FILE="$f"
  [ "$id" ] && [ "$f" ] && [ ! -e "$f" ] && { gpg --armor --output "$f" --export-secret-keys "$id" ; echo "output:$f" ; }
}
# fun usage
#gpg_pri_key_export
#gpg_pri_key_export "$GPG_USER_ID" "$GPG_PRI_KEY_FILE"

function gpg_pri_key_import(){
  echo "# 导入私钥"
  local f= ; [ "${1}" ] && f="${1}" ; [ -z "$f" ] && f="$GPG_PRI_KEY_FILE" ; [ -z "$f" ] && f="" ;
  [ "$f" ] && GPG_PRI_KEY_FILE="$f"
  [ "$f" ] && [ -e "$f" ] && gpg --import "$f"
}
# fun usage
#gpg_pri_key_import
#gpg_pri_key_import "$GPG_PRI_KEY_FILE"

function gpg_pub_key_export(){
  echo "# 导出公钥"
  local id= ; [ "${1}" ] && id="${1}" ; [ -z "$id" ] && id="$GPG_USER_ID" ; [ -z "$id" ] && id="" ;
  [ "$id" ] && GPG_USER_ID="$id"

  local f= ; [ "${2}" ] && f="${2}" ; [ -z "$f" ] && f="$GPG_PUB_KEY_FILE" ; [ -z "$f" ] && f="" ;
  [ "$f" ] && GPG_PUB_KEY_FILE="$f"

  [ "$f" ] && [ ! -e "$f" ] &&  { gpg --armor --output "$f" --export "$id" ; echo "output:$f" ; }
  #armor参数可以将其转换为ASCII码显示
  #[ ! -e "$f" ] && gpg --armor --export "$id" > "$f"
}
# fun usage
#gpg_pub_key_export
#gpg_pub_key_export "$GPG_USER_ID" "$GPG_PUB_KEY_FILE"

function gpg_pub_key_upload(){
  echo "# 上传公钥"
  echo "note:将公钥上传到公钥服务器 $server"

  local id= ; [ "${1}" ] && id="${1}" ; [ -z "$id" ] && id="$GPG_USER_ID" ; [ -z "$id" ] && id="" ;
  [ "$id" ] && GPG_USER_ID="$id"

  local f= ; [ "${2}" ] && f="${2}" ; [ -z "$f" ] && f="$PUB_KEY_SERVER" ; [ -z "$f" ] && f="hkp://ipv4.pool.sks-keyservers.net" ;
  [ "$f" ] && PUB_KEY_SERVER="$f"
  #gpg --send-keys "$id" --keyserver "$f" # gpg: Note: '--keyserver' is not considered an option ?

  #echo "gpg --keyserver \"$f\" --send-keys \"$id\""
  gpg --keyserver "$f" --send-keys "$id"

  #gpg --keyserver hkp://pool.sks-keyservers.net --send-keys  7DE42532F2004696779CBC5B2E22CBF6FADEA436
  #gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --send-keys  7DE42532F2004696779CBC5B2E22CBF6FADEA436
}
# fun usage
#gpg_pub_key_upload
#gpg_pub_key_upload "$GPG_USER_ID" "hkp://ipv4.pool.sks-keyservers.net"
#gpg_pub_key_upload "$GPG_USER_ID" "$PUB_KEY_SERVER"

function gpg_pub_key_search(){
  echo "# 搜索公钥"
  echo "note:在公钥服务器 $server中搜索"
  local id= ; [ "${1}" ] && id="${1}" ; [ -z "$id" ] && id="$GPG_USER_ID" ; [ -z "$id" ] && id="" ;
  [ "$id" ] && GPG_USER_ID="$id"

  local f= ; [ "${2}" ] && f="${2}" ; [ -z "$f" ] && f="$PUB_KEY_SERVER" ; [ -z "$f" ] && f="hkp://ipv4.pool.sks-keyservers.net" ;
  [ "$f" ] && PUB_KEY_SERVER="$f"

  gpg --keyserver "$f" --search-keys "$id"
}
# fun usage
#gpg_pub_key_search
#gpg_pub_key_search "$GPG_USER_ID" "hkp://ipv4.pool.sks-keyservers.net"
#gpg_pub_key_search "$GPG_USER_ID" "$PUB_KEY_SERVER"

function gpg_pub_key_download(){
  echo "# 下拉公钥"
  echo "note:从公钥服务器 $server中下载"
  local id= ; [ "${1}" ] && id="${1}" ; [ -z "$id" ] && id="$GPG_USER_ID" ; [ -z "$id" ] && id="" ;
  [ "$id" ] && GPG_USER_ID="$id"

  local f= ; [ "${2}" ] && f="${2}" ; [ -z "$f" ] && f="$PUB_KEY_SERVER" ; [ -z "$f" ] && f="hkp://ipv4.pool.sks-keyservers.net" ;
  [ "$f" ] && PUB_KEY_SERVER="$f"

  gpg --keyserver "$f" --receive-keys "$id"
}
# fun usage
#gpg_pub_key_download
#gpg_pub_key_download "$GPG_USER_ID" "hkp://ipv4.pool.sks-keyservers.net"
#gpg_pub_key_download "$GPG_USER_ID" "$PUB_KEY_SERVER"

function gpg_pub_key_check(){
  echo "# 验证公钥"
  echo "note:在网站上公布一个公钥指纹，让其他人核对下载到的公钥是否为真。"
  echo "note:todos"
  local id= ; [ "${1}" ] && id="${1}" ; [ -z "$id" ] && id="$GPG_USER_ID" ; [ -z "$id" ] && id="" ;
  [ "$id" ] && GPG_USER_ID="$id"

  #2生成公钥指纹
  gpg --fingerprint "$id"
  #...
  # todos
}
# fun usage
#gpg_pub_key_check
#gpg_pub_key_check "$GPG_USER_ID"

function gpg_pub_key_revoke(){
  echo "# 撤销公钥"
  echo "note:在公钥服务器 $server 中的公钥作废"
  echo "note:todos"
  local id= ; [ "${1}" ] && id="${1}" ; [ -z "$id" ] && id="$GPG_USER_ID" ; [ -z "$id" ] && id="" ;
  [ "$id" ] && GPG_USER_ID="$id"
  local s= ; [ "${2}" ] && s="${2}" ; [ -z "$s" ] && s="$PUB_KEY_SERVER" ; [ -z "$s" ] && s="hkp://ipv4.pool.sks-keyservers.net" ;
  [ "$s" ] && PUB_KEY_SERVER="$s"

  local f= ; [ "${3}" ] && f="${3}" ; [ -z "$f" ] && f="$GPG_REV_KEY_FILE" ; [ -z "$f" ] && f="t" ;
  [ "$f" ] && GPG_REV_KEY_FILE="$f"


  #2生成撤销证书
  gpg --gen-revoke "$id" --output "$f"
  #...
  gpg --send-keys "$id" --keyserver "$s"
}
# fun usage
#gpg_pub_key_revoke
#gpg_pub_key_revoke "$GPG_USER_ID" "$PUB_KEY_SERVER" "$GPG_REV_KEY_FILE"

function gpg_pub_key_import(){
  echo "# 导入公钥"
  local f= ; [ "${1}" ] && f="${1}" ; [ -z "$f" ] && f="$GPG_PUB_KEY_FILE" ; [ -z "$f" ] && f="" ;
  [ "$f" ] && GPG_PUB_KEY_FILE="$f"
  [ "$f" ] && [ ! -e "$f" ] && gpg --import "$f"
}
# fun usage
#gpg_pub_key_import
#gpg_pub_key_import "$GPG_PUB_KEY_FILE"

function gpg_rev_key_export(){
  echo "# 回收证书-导出"
  local id= ; [ "${1}" ] && id="${1}" ; [ -z "$id" ] && id="$GPG_USER_ID" ; [ -z "$id" ] && id="" ;
  [ "$id" ] && GPG_USER_ID="$id"

  local f= ; [ "${2}" ] && f="${2}" ; [ -z "$f" ] && f="$GPG_REV_KEY_FILE" ; [ -z "$f" ] && f="t" ;
  [ "$f" ] && GPG_REV_KEY_FILE="$f"

  #2生成撤销证书
  #[ ! -e "$f" ] && gpg --gen-revoke "$id" --output "$f"
  [ "$f" ] && [ ! -e "$f" ] && gpg --gen-revoke "$id" > "$f"
}
# fun usage
#gpg_rev_key_export
#gpg_rev_key_export "$GPG_USER_ID" "$GPG_REV_KEY_FILE"

function gpg_rev_key_import(){
  echo "# 回收证书-导入"
  local f= ; [ "${1}" ] && f="${1}" ; [ -z "$f" ] && f="$GPG_REV_KEY_FILE" ; [ -z "$f" ] && f="" ;
  [ "$f" ] && GPG_REV_KEY_FILE="$f"
  [ "$f" ] && [ ! -e "$f" ] &&  gpg --import "$f"
}
# fun usage
#gpg_rev_key_import
#gpg_rev_key_import "$GPG_REV_KEY_FILE"


function gpg_file_encode(){
  echo "# 加密文件"
  local id= ; [ "${1}" ] && id="${1}" ; [ -z "$id" ] && id="$GPG_USER_ID" ; [ -z "$id" ] && id="" ;
  [ "$id" ] && GPG_USER_ID="$id"

  local name=
  [ "${2}" ] && name="${2}"
  [ -z "$name" ] && name="$ENCODE_FILE_NAME"
  [ -z "$name" ] && name=
  [ "$name" ] && ENCODE_FILE_NAME="$name"

  local suffix=
  [ "${3}" ] && suffix="${3}"
  [ -z "$suffix" ] && suffix="$ENCODE_FILE_SUFFIX"
  [ -z "$suffix" ] && suffix=
  [ "$suffix" ] && ENCODE_FILE_SUFFIX="$suffix"

  local src=
  local des=
  src="${name}.${suffix}"
  des="${name}.en.${suffix}"
  #gpg --recipient "$id" --encrypt "$src" --output "$des" # error
  # fix in gpg (GnuPG) 2.2.20 ;desc=Note: '--output' is not considered an option
  gpg --recipient "$id" --output "$des" --encrypt "$src"
}
# fun usage
#gpg_file_encode
#gpg_file_encode "$GPG_USER_ID" "lang-$ver.all" "tar.gz"
#gpg_file_encode "$GPG_USER_ID" "$ENCODE_FILE_NAME" "$ENCODE_FILE_SUFFIX"

function gpg_file_decode(){
  echo "# 解密文件"
  local id= ; [ "${1}" ] && id="${1}" ; [ -z "$id" ] && id="$GPG_USER_ID" ; [ -z "$id" ] && id="" ;
  [ "$id" ] && GPG_USER_ID="$id"

  local name=
  [ "${2}" ] && name="${2}"
  [ -z "$name" ] && name="$DECODE_FILE_NAME"
  [ -z "$name" ] && name=
  [ "$name" ] && DECODE_FILE_NAME="$name"

  local suffix=
  [ "${3}" ] && suffix="${3}"
  [ -z "$suffix" ] && suffix="$DECODE_FILE_SUFFIX"
  [ -z "$suffix" ] && suffix=
  [ "$suffix" ] && DECODE_FILE_SUFFIX="$suffix"

  local src=
  local des=
  des="${name}.${suffix}"
  src="${name}.en.${suffix}"
  #gpg --decrypt "$src" --output "$des" # error
  # fix gpg: Note: '--output' is not considered an option
  gpg --output "$des" --decrypt "$src"
  #des="${name}.de.${suffix}"
  #gpg --output "$des" --decrypt "$src"
}
# fun usage
#gpg_file_decode
#gpg_file_decode "$GPG_USER_ID" "lang-$ver.all" "tar.gz"
#gpg_file_decode "$GPG_USER_ID" "$DECODE_FILE_NAME" "$DECODE_FILE_SUFFIX"


function gpg_file_sign(){
  echo "# 签名文件"
  local n1=
  [ "${1}" ] && n1="${1}"
  [ -z "$n1" ] && n1="$SIGN_FILE_NAME"
  [ -z "$n1" ] && n1=password
  [ "$n1" ] && SIGN_FILE_NAME="$n1"

  local n2=
  [ "${2}" ] && n2="${2}"
  [ -z "$n2" ] && n2="$SIGN_FILE_SUFFIX"
  [ -z "$n2" ] && n2=txt
  [ "$n2" ] && SIGN_FILE_SUFFIX="$n2"

  local t=
  [ "${3}" ] && t="${3}"
  [ -z "$t" ] &&  t="$SIGN_FILE_TYPE"
  [ -z "$t" ] && t="txt+sign"
  [ "$t" ] && SIGN_FILE_TYPE="$t"

  local file=
  file="${n1}.${n2}"

  #2 以二进制式存储+合并式的=数字签名+合并式的
  [ -e "$file" ] && [ _"$t" = _"bin" ] && {
      echo "sign file and gen file $file.gpg ..." ;
      gpg --sign "$file";
  }

  #2 以文本形式存储+合并式的=文本签名+合并式的
  [ -e "$file" ] && [ _"$t" = _"txt" ] && {
      echo "sign file and gen file $file.asc ..." ;
      gpg --clearsign "$file";
  }

  #2 以二进制式存储+分离式的=数字签名+分离式的
  [ -e "$file" ] && [ _"$t" = _"bin+sign" ] && {
      echo "sign file and gen file $file.sig ..." ;
      gpg --detach-sign  "$file";
  }
  #2 以文本形式存储+签名文件=文本签名+分离式的
  [ -e "$file" ] && [ _"$t" = _"txt+sign" ] && {
      echo "sign file and gen file $file.asc ..." ;
      gpg --armor --detach-sign  "$file";
  }
}
# fun usage
#gpg_file_sign
#gpg_file_sign "password" "txt" "txt"
#gpg_file_sign "lang-$ver.all" "tar.gz" "txt+sign"
#gpg_file_sign "$SIGN_FILE_NAME" "$SIGN_FILE_SUFFIX" "$SIGN_FILE_TYPE"


function gpg_file_checksign(){
  echo "# 验证签名"
  local n1=
  [ "${1}" ] && n1="${1}"
  [ -z "$n1" ] && n1="$SIGN_FILE_NAME"
  [ -z "$n1" ] && n1=password
  [ "$n1" ] && SIGN_FILE_NAME="$n1"

  local n2=
  [ "${2}" ] && n2="${2}"
  [ -z "$n2" ] && n2="$SIGN_FILE_SUFFIX"
  [ -z "$n2" ] && n2=txt
  [ "$n2" ] && SIGN_FILE_SUFFIX="$n2"

  local t=
  [ "${3}" ] && t="${3}"
  [ -z "$t" ] &&  t="$SIGN_FILE_TYPE"
  [ -z "$t" ] && t="txt+sign"
  [ "$t" ] && SIGN_FILE_TYPE="$t"

  local file=
  file="${n1}.${n2}"

  # 文本签名+合并式的
  #[ _"$t" = _"txt" ] && gpg --verify "${1}.${n2}.asc"
  [ _"$t" = _"txt" ] && [ -e "$file.asc" ] && gpg --verify "${1}.${n2}.asc" "${1}.${n2}"
  # 文本签名+分离式的
  [ _"$t" = _"txt+sign" ] && [ -e "$file.asc" ] && gpg --verify "${1}.${n2}.asc" "${1}.${n2}"
  # 数字签名+合并式的
  [ _"$t" = _"bin" ] && [ -e "$file.gpg" ] && gpg --verify "${1}.${n2}.gpg"
  # 数字签名+分离式的
  [ _"$t" = _"bin+sign" ] && [ -e "$file.sig" ] && gpg --verify "${1}.${n2}.sig" "${1}.${n2}"
}
# fun usage
#gpg_file_checksign
#gpg_file_checksign "password" "txt" "txt"
#gpg_file_checksign "lang-$ver.all" "tar.gz" "txt+sign"
#gpg_file_checksign "$SIGN_FILE_NAME" "$SIGN_FILE_SUFFIX" "$SIGN_FILE_TYPE"

function gpg_passphrase_change(){
  local id= ; [ "${1}" ] && id="${1}" ; [ -z "$id" ] && id="$GPG_USER_ID" ; [ -z "$id" ] && id="" ;
  [ "$id" ] && GPG_USER_ID="$id"
  echo "# 修改密码"
  echo 'step 1. go in to gpg cli:gpg --edit-key "$id"'
  echo "step 2. to update password:password"
  echo "step 3. to save password:save"
  gpg --edit-key "$id"
  #gpg2 --edit-key "$id"
  # then write password
}
# fun usage
#gpg_passphrase_change
#gpg_passphrase_change "$GPG_USER_ID"



function gpg_var_ini(){
  echo "# 变量始化"
# [curd]
GPG_KEY_LENGTH=2048
GPG_KEY_TYPE=RSA
GPG_KEY_EXP=0 # eg:365|12m|1y
GPG_USER_NAME=yemiancheng
GPG_USER_NOTE=ymc-github
GPG_USER_EMAIL=ymc.github@gmail.com
GPG_USER_ID= # will be gen
GPG_KEY_PATH=~/.gnupg
# gpg_var_cal
#PUB_KEY_SERVER="hkp://subkeys.pgp.net"
#PUB_KEY_SERVER=hkp://p80.pool.sks-keyservers.net:80
PUB_KEY_SERVER=hkp://ipv4.pool.sks-keyservers.net
#PUB_KEY_SERVER=hkp://pgp.mit.edu:80

# [encode]
ENCODE_FILE_NAME=SHASUMS256
ENCODE_FILE_SUFFIX="txt"
# [decode]
DECODE_FILE_NAME=SHASUMS256
DECODE_FILE_SUFFIX="txt"
# [sign]
SIGN_FILE_NAME=SHASUMS256
SIGN_FILE_SUFFIX=txt
SIGN_FILE_TYPE=txt
}
# fun usage
#gpg_var_ini


function gpg_var_cal(){
  echo "# 变量计算"
GPG_CNF_KEY_NAME="gpg.$GPG_USER_NOTE.cnf"
GPG_PUB_KEY_NAME="gpg.$GPG_USER_NOTE.pub"
GPG_PRI_KEY_NAME="gpg.$GPG_USER_NOTE.pri"
GPG_REV_KEY_NAME="gpg.$GPG_USER_NOTE.rev"
GPG_SEC_KEY_NAME="gpg.$GPG_USER_NOTE.sec"
GPG_CNF_KEY_FILE="${GPG_KEY_PATH}/${GPG_CNF_KEY_NAME}.txt"
GPG_PUB_KEY_FILE="${GPG_KEY_PATH}/${GPG_PUB_KEY_NAME}.txt"
GPG_PRI_KEY_FILE="${GPG_KEY_PATH}/${GPG_PRI_KEY_NAME}.txt"
GPG_REV_KEY_FILE="${GPG_KEY_PATH}/${GPG_REV_KEY_NAME}.txt"
GPG_SEC_KEY_FILE="${GPG_KEY_PATH}/${GPG_SEC_KEY_NAME}.txt"
}
# fun usage
#gpg_var_cal

function gpg_backup_file_gen(){
  local list=
  local i=
  local src=
  local des=

  local p2=
  [ "${1}" ] && p2="${1}"
  [ -z "$p2" ] && p2="$BACKUP_DES_PATH"
  [ -z "$p2" ] && p2=secret

  local pr=
  [ "${2}" ] && pr="${2}"
  [ -z "$pr" ] && pr="$GPG_KEY_PATH"
  [ -z "$pr" ] && pr=~/.gnupg

  echo "# 备份文件"
  # step-x: back up gpg pri key file
  src="$GPG_PRI_KEY_FILE"
  des=$(echo "$GPG_PRI_KEY_FILE" | sed "s#$pr#$p2#")
  [ -e "$src" ] && [ ! -e "$des" ] && echo "$des" && cp -rf "$src" "$des"
  # step-x: back up gpg pub key file
  src="$GPG_PUB_KEY_FILE"
  des=$(echo "$GPG_PUB_KEY_FILE" | sed "s#$pr#$p2#")
  [ -e "$src" ] && [ ! -e "$des" ] && echo "$des" && cp -rf "$src" "$des"
  # step-x: back up gpg rev key file
  src="$GPG_REV_KEY_FILE"
  des=$(echo "$GPG_REV_KEY_FILE" | sed "s#$pr#$p2#")
  [ -e "$src" ] && [ ! -e "$des" ] && echo "$des" && cp -rf "$src" "$des"
  # step-x: back up gpg sec key file
  src="$GPG_SEC_KEY_FILE"
  des=$(echo "$GPG_SEC_KEY_FILE" | sed "s#$pr#$p2#")
  [ -e "$src" ] && [ ! -e "$des" ] && echo "$des" && cp -rf "$src" "$des"

}
# fun usage
# gpg_backup_file_gen
# gpg_backup_file_gen "secret" ~/.gnupg
# gpg_backup_file_gen "secret/gpg" ~/.gnupg
# gpg_backup_file_gen "$des_dir" "$src_dir"
# gpg_backup_file_gen "$des_dir" "$GPG_KEY_PATH"

function gpg_backup_file_del(){
  local list=
  local i=
  local src=
  local des=

  local p2=
  [ "${1}" ] && p2="${1}"
  [ -z "$p2" ] && p2="$BACKUP_DES_PATH"
  [ -z "$p2" ] && p2=secret

  local pr=
  [ "${2}" ] && pr="${2}"
  [ -z "$pr" ] && pr="$GPG_KEY_PATH"
  [ -z "$pr" ] && pr=~/.gnupg
  echo "# 删除备份"
  src="$GPG_PRI_KEY_FILE"
  des=$(echo "$GPG_PRI_KEY_FILE" | sed "s#$pr#$p2#")
  [ -e "$des" ] && echo "$des" && rm -rf "$des"
  src="$GPG_PUB_KEY_FILE"
  des=$(echo "$GPG_PUB_KEY_FILE" | sed "s#$pr#$p2#")
  [ -e "$des" ] && echo "$des" && rm -rf "$des"
  src="$GPG_REV_KEY_FILE"
  des=$(echo "$GPG_REV_KEY_FILE" | sed "s#$pr#$p2#")
  [ -e "$des" ] && echo "$des" && rm -rf "$des"
  src="$GPG_SEC_KEY_FILE"
  des=$(echo "$GPG_SEC_KEY_FILE" | sed "s#$pr#$p2#")
  [ -e "$des" ] && echo "$des" && rm -rf "$des"
}
# fun usage
# gpg_backup_file_del
# gpg_backup_file_del "secret" ~/.gnupg
# gpg_backup_file_del "secret/gpg" ~/.gnupg
# gpg_backup_file_del "$des_dir" "$src_dir"
# gpg_backup_file_del "$des_dir" "$GPG_KEY_PATH"

function gpg_sec_id_get_by_name_and_mail(){
  echo "# 密钥编号-获取"
  local name= ; [ "${1}" ] && name="${1}" ; [ -z "$name" ] && name="yemiancheng" ;
  local mail= ; [ "${2}" ] && mail="${2}" ; [ -z "$mail" ] && mail="hualei03042013@163.com" ;
  local uid= ; uid="$name <$mail>"
  # step-x: list and get the line before match pattern
  # step-x: get str begin with sec
  # step-x: only get the first line
  # step-x: delete more than one space to one
  [ "$uid" ] &&  {
    GPG_SEC_ID=$(gpg --list-secret-keys --keyid-format LONG |  grep -B 2 "$uid" | grep "^sec" | sed -n "1p" |sed "s# +# #g" | cut -d " " -f 4 | cut -d "/" -f 2) ;
    echo "$GPG_SEC_ID" ;
  }
}
# fun usage
#gpg_sec_id_get_by_name_and_mail
#

function gpg_sec_key_export(){
  echo "# 密钥文件-导出"
  # step-x: passed id with arg
  local id= ; [ "${1}" ] && id="${1}" ; [ -z "$id" ] && id="$GPG_SEC_ID" ; [ -z "$id" ] && id="" ;
  local f= ; [ "${2}" ] && f="${2}" ; [ -z "$f" ] && f="$GPG_SEC_KEY_FILE" ; [ -z "$f" ] && f="" ;
  # step-x: update GPG_SEC_ID with arg
  [ "$id" ] && GPG_SEC_ID="$id"
  # step-x: update GPG_SEC_KEY_FILE with arg
  [ "$f" ] && GPG_SEC_KEY_FILE="$f"
  [ "$id" ] && [ "$f" ] && [ ! -e "$f" ] && { gpg --armor --export "$id" > "$f" ; echo "output:$f" ; }
}
# fun usage
#gpg_sec_key_export
#gpg_sec_key_export "$GPG_SEC_ID" "$GPG_SEC_KEY_FILE"

function gpg_sec_key_to_github(){
  echo "# 密钥文件-上传"
  echo "note:1. to github"
  echo "note:2. todos"
  echo "note:3. now only copy"
  local f= ; [ "${1}" ] && f="${1}" ; [ -z "$f" ] && f="$GPG_SEC_KEY_FILE" ; [ -z "$f" ] && f="" ;
  [ "$f" ] && GPG_SEC_KEY_FILE="$f"
  [ -e "$f" ] &&  cat "$f" | clip
}
# fun usage
#gpg_sec_key_to_github
#gpg_sec_key_to_github "$GPG_SEC_KEY_FILE"

function gpg_sec_id_to_git(){
  echo "# 密钥编号-上传"
  echo "steps:"
  echo "1. get secret id"
  echo "2. get secret key"
  echo "3. put secret key to github/gitlab/gitee ..."
  echo "4. put secret id to git"
  echo "   eg:git config --global user.signingkey $id"
  echo "   eg:git config user.signingkey $id"
  echo "5. tell git use gpg sign when commit"
  echo "   eg:git config --global commit.gpgsign true"
  echo "   eg:git config commit.gpgsign true"
  echo "6. it will check when:git commit or git commit -S"
  echo "7. it will get Verified label in github/gitlab/gitee"
  echo "#note:now is step 4,5"

  local id= ; [ "${1}" ] && id="${1}" ; [ -z "$id" ] && id="$GPG_SEC_ID" ; [ -z "$id" ] && id="" ;
  local sc= ; [ "${2}" ] && sc="${2}" ; [ -z "$sc" ] && sc="$GPG_GIT_SCOPE" ; [ -z "$sc" ] && sc="local" ;
  # step-x: update relative var
  [ "$id" ] && GPG_SEC_ID="$id"
  [ "$sc" ] && GPG_GIT_SCOPE="$sc"
  # local project
  [ _"$sc" = _"local" ] && {
    git config --global user.signingkey "$id" ;
    git config commit.gpgsign true ;
  }
  # all project
  [ _"$sc" = _"global" ] && {
    git config --global user.signingkey $id
    git config --global commit.gpgsign true ;
  }

}
# fun usage
# gpg_sec_id_to_git
# gpg_sec_id_to_git "$GPG_SEC_ID" "local"
# gpg_sec_id_to_git "$GPG_SEC_ID" "global"
# gpg_sec_id_to_git "$GPG_SEC_ID" "$GPG_GIT_SCOPE"

# file usage
# ./secret/sh-lib-gpg.sh"
# source "${THIS_FILE_PATH}/sh-lib-gpg.sh"
# source "${SRC_PATH}/sh-lib-gpg.sh"
# source "${SECRET_PATH}/sh-lib-gpg.sh"
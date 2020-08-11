#!/bin/sh

###
# deps
###

###
# apis
###
function ssh_var_config(){
  local user=
  local ip=
  local key_f=
  local key_p=
  local port=

  [ "${1}" ] && ip="${1}"
  [ -z "$ip" ] && ip="192.168.56.3"

  [ "${2}" ] && user="${2}"
  [ -z "$user" ] && user="root"

  [ "${3}" ] && key_f="${3}"
  [ -z "$key_f" ] && key_f="20-06-16"

  [ "${4}" ] && key_p="${4}"
  [ -z "$key_f" ] && key_p=~/.ssh/

  [ "${5}" ] && port="${5}"
  [ -z "$port" ] && port=22

  echo "## 配置变量"
  PRIVITE_KEY_FILE_NAME="$key_f"
  PRIVITE_KEY_FILE_PATH="$key_p"
  SSH_SERVER_IP="$ip"
  SSH_SERVER_USER="$user"
  SSH_SERVER_PORT="$port"
  PUBLIC_KEY_FILE_NAME=${PRIVITE_KEY_FILE_NAME}.pub
}
# ssh_var_config "192.168.56.3" "root" "20-06-16" ~/.ssh/
# ssh_var_config "192.168.56.3" "root" "20-06-16" "./"

function ssh_var_caculate(){
  echo "## 计算变量"
  PRIVITE_KEY_FILE_NAME=$(cache_get_val_by_key "ssh.key.file")
  PRIVITE_KEY_FILE_PATH=$(cache_get_val_by_key "ssh.key.path")
  SSH_SERVER_IP=$(cache_get_val_by_key "ssh.ip")
  SSH_SERVER_USER=$(cache_get_val_by_key "ssh.user")
  SSH_SERVER_PORT=$(cache_get_val_by_key "ssh.port")
  PUBLIC_KEY_FILE_NAME=${PRIVITE_KEY_FILE_NAME}.pub
}
# ssh_var_caculate

function ssh_secret_key_list(){
  echo "## 列出密钥"
  ls $PRIVITE_KEY_FILE_PATH | grep $PRIVITE_KEY_FILE_NAME
  cat ~/.ssh/known_hosts
}
#ssh_secret_key_list

function ssh_secret_key_list_some(){
  echo "## 列出密钥"
  ls ~/.ssh/ | grep -v -E "(config)|(known_hosts)"
}
#ssh_secret_key_list_some

function ssh_secret_key_gen(){
  echo "## 生成密钥"
  WORKING_FILE="${PRIVITE_KEY_FILE_PATH}${PRIVITE_KEY_FILE_NAME}"
  #[ ! -e "$WORKING_FILE" ] && ssh-keygen -t rsa -f "$WORKING_FILE" -C $SSH_SERVER_USER
  [ ! -e "$WORKING_FILE" ] && ssh-keygen -p "" -t rsa -f "$WORKING_FILE" -C $SSH_SERVER_USER
  #[ ! -e "$WORKING_FILE" ] && ssh-keygen -P "$SSH_KEY_PASSPHRASE" -t rsa -f "$WORKING_FILE" -C $SSH_SERVER_USER
}
#ssh_secret_key_gen

function ssh_secret_key_del(){
  echo "## 删除密钥"
  WORKING_FILE="${PRIVITE_KEY_FILE_PATH}${PRIVITE_KEY_FILE_NAME}" ; [ -e "$WORKING_FILE" ] && rm -rf "$WORKING_FILE"
  WORKING_FILE="${PRIVITE_KEY_FILE_PATH}${PRIVITE_KEY_FILE_NAME}.pub" ; [ -e "$WORKING_FILE" ] && rm -rf "$WORKING_FILE"
}
#ssh_secret_key_del

function ssh_secret_key_get(){
  echo "## 查看密钥"
  WORKING_FILE="${PRIVITE_KEY_FILE_PATH}${PRIVITE_KEY_FILE_NAME}" ; [ -e "$WORKING_FILE" ] && cat "$WORKING_FILE"
  WORKING_FILE="${PRIVITE_KEY_FILE_PATH}${PRIVITE_KEY_FILE_NAME}.pub" ; [ -e "$WORKING_FILE" ] && cat "$WORKING_FILE"
}
#ssh_secret_key_get


# 检测公钥是否创建。
function ssh_key_check(){
  local f=
  local p=
  [ "${1}" ] && f="${1}"
  [ -z "$f" ] && f="id_rsa"
  [ "${2}" ] && p="${2}"
  [ -z "$p" ] && p=~/.ssh
  #[ ! -f "${p}/${f}" ]
  [ ! -e "${p}/${f}" ] && ssh-keygen -p "" -t rsa -f "${p}/${f}" -C $SSH_SERVER_USER
}
# ssh_key_check "20-06-24" ~/.ssh
#ssh_key_check "20-06-25" ~/.ssh


function ssh_pub_key_get(){
  echo "## 查看公钥"
  WORKING_FILE="${PRIVITE_KEY_FILE_PATH}${PUBLIC_KEY_FILE_NAME}"
  [ -e "$WORKING_FILE" ] && cat "$WORKING_FILE"
}
#ssh_pub_key_get
function ssh_pub_key_copy(){
  echo "## 复制公钥"
  WORKING_FILE="${PRIVITE_KEY_FILE_PATH}${PUBLIC_KEY_FILE_NAME}"
  [ -e "$WORKING_FILE" ] && cat "$WORKING_FILE" | clip
}
#ssh_pub_key_copy
function ssh_pub_key_upload(){
  echo "## 上传公钥"
  WORKING_FILE="${PRIVITE_KEY_FILE_PATH}${PRIVITE_KEY_FILE_NAME}"
  [ -e "$WORKING_FILE" ] && ssh-copy-id -i ${PRIVITE_KEY_FILE_PATH}${PUBLIC_KEY_FILE_NAME} $SSH_SERVER_USER@$SSH_SERVER_IP -p $SSH_SERVER_PORT
}
#ssh_pub_key_upload
function ssh_pub_key_copy_id_to_ms(){
  ssh_pub_key_upload
}
#ssh_pub_key_copy_id_to_ms

## ssh公钥推送-免交互
function ssh_pub_key_copy_id_to_ms_by_expect0(){
  echo "## 上传公钥"
 local ip=
  local sp=

  [ "${1}" ] && ip="${1}"
  [ -z "$ip" ] && ip="192.168.122.2"

  [ "${2}" ] && sp="${2}"
  [ -z "$sp" ] && sp="centos"

/usr/bin/expect <<-EOF
set timeout 10
#spawn ssh-copy-id $ip
spawn ssh-copy-id -i ${PRIVITE_KEY_FILE_PATH}${PUBLIC_KEY_FILE_NAME} $SSH_SERVER_USER@$SSH_SERVER_IP -p $SSH_SERVER_PORT
expect {
        "yes/no" { send "yes\r"; exp_continue }
        "password:" { send "$sp\r" }
}
expect eof
EOF
}
#ssh_pub_key_copy_id_to_ms_by_expect0
# ssh_pub_key_copy_id_to_ms_by_expect0
# ssh_pub_key_copy_id_to_ms_by_expect0 "192.168.122.2" "centos"
# ssh_pub_key_copy_id_to_ms_by_expect0 "$ip" "$pass"

## ssh公钥推送-免交互
function ssh_pub_key_copy_id_to_ms_by_expect(){
  echo "## 上传公钥"
 local ip=
  local sp=
  local user=
  local key_f=

  [ "${1}" ] && ip="${1}"
  [ -z "$ip" ] && ip="192.168.122.2"

  [ "${2}" ] && sp="${2}"
  [ -z "$sp" ] && sp="centos"

  [ "${3}" ] && user="${3}"
  [ -z "$user" ] && user=root

  [ "${4}" ] && key_f="${4}"
  [ -z "$key_f" ] && key_f=~/.ssh/20-06-16

  #[ -e "$key_f" ] && ssh-copy-id -i "$key_f.pub" $user@$ip

/usr/bin/expect <<-EOF
set timeout 10
#spawn ssh-copy-id $ip
spawn ssh-copy-id -i "$key_f.pub" $user@$ip  -p $SSH_SERVER_PORT
expect {
        "yes/no" { send "yes\r"; exp_continue }
        "password:" { send "$sp\r" }
}
expect eof
EOF
}
#ssh_pub_key_copy_id_to_ms_by_expect
# ssh_pub_key_copy_id_to_ms_by_expect
# ssh_pub_key_copy_id_to_ms_by_expect "192.168.122.2" "centos"
# ssh_pub_key_copy_id_to_ms_by_expect "$ip" "$pass"

function ssh_pri_key_get(){
  echo "## 查看私钥"
  WORKING_FILE="${PRIVITE_KEY_FILE_PATH}${PRIVITE_KEY_FILE_NAME}"
  [ -e "$WORKING_FILE" ] && cat "$WORKING_FILE"
}
#ssh_pri_key_get

function ssh_pri_key_push(){
  echo "## 添加私钥"
  echo "#2 添加私钥--添加私钥到~/.ssh/known_hosts文件当中"
  cat ~/.ssh/known_hosts | grep "$SSH_SERVER_IP"
  [ $? -ne 0 ] && eval $(ssh-agent -s) && ssh-add ${PRIVITE_KEY_FILE_PATH}${PRIVITE_KEY_FILE_NAME}
}
#ssh_pri_key_push
function ssh_pri_key_add_to_known_host(){
  ssh_pri_key_push
}
#ssh_pri_key_add_to_known_host

function ssh_pto_vm(){
  local shcode=
  [ "${1}" ] && shcode="${1}"
  [ -z "$shcode" ] && shcode=""

  echo "## 密码登录"
  if [ -n "${1}" ] ; then
    ssh  $SSH_SERVER_USER@$SSH_SERVER_IP -p $SSH_SERVER_PORT "$shcode"
  else
     ssh  $SSH_SERVER_USER@$SSH_SERVER_IP -p $SSH_SERVER_PORT
  fi
}
#ssh_pto_vm

# ssh密码登录-免交互
function ssh_pto_vm_expect(){
  local shcode=
  [ "${1}" ] && shcode="${1}"
  [ -z "$shcode" ] && shcode=""

  local sp=
  [ "${2}" ] && sp="${2}"
  [ -z "$sp" ] && sp="centos"

  echo "## 密码登录"

/usr/bin/expect <<-EOF
set timeout 10
if [ -n "$shcode" ] ; then
  ssh  $SSH_SERVER_USER@$SSH_SERVER_IP "$shcode"
else
     ssh  $SSH_SERVER_USER@$SSH_SERVER_IP -p $SSH_SERVER_PORT
fi
expect {
        "yes/no" { send "yes\r"; exp_continue }
        "password:" { send "$sp\r" }
}
expect eof
EOF
}
#ssh_pto_vm_expect
#ssh_pto_vm_expect "" "$pass"

function ssh_to_vm(){
  local shcode=
  [ "${1}" ] && shcode="${1}"
  [ -z "$shcode" ] && shcode=""
  local fun_note=
  fun_note=$(cat<<EOF
   ssh -i ${PRIVITE_KEY_FILE_PATH}${PRIVITE_KEY_FILE_NAME} $SSH_SERVER_USER@$SSH_SERVER_IP -p $SSH_SERVER_PORT
EOF
)

  echo "## 免密登录"
  echo "$fun_note"
  if [ -n "${1}" ] ; then
    ssh -i ${PRIVITE_KEY_FILE_PATH}${PRIVITE_KEY_FILE_NAME} $SSH_SERVER_USER@$SSH_SERVER_IP -p $SSH_SERVER_PORT "$shcode"
  else
    ssh -i ${PRIVITE_KEY_FILE_PATH}${PRIVITE_KEY_FILE_NAME} $SSH_SERVER_USER@$SSH_SERVER_IP -p $SSH_SERVER_PORT
  fi

}
#ssh_to_vm

function print_ssh_to_vm(){
  echo "## 免密登录"
  echo "ssh -i \"${PRIVITE_KEY_FILE_PATH}${PRIVITE_KEY_FILE_NAME}\" $SSH_SERVER_USER@$SSH_SERVER_IP -p $SSH_SERVER_PORT"
}
#print_ssh_to_vm

function ssh_all_key_scp_to_ms(){
  local SRC=
  local DES=
  local KEY=
  local SRC_P=
  local DES_P=
  [ "${1}" ] && SRC="${1}"
  [ -z "$SRC" ] && SRC="${PRIVITE_KEY_FILE_NAME}"
  [ "${2}" ] && DES="${2}"
  [ -z "$DES" ] && DES="${PRIVITE_KEY_FILE_NAME}"
  [ "${3}" ] && SRC_P="${3}"
  [ -z "$SRC_P" ] && SRC_P="${PRIVITE_KEY_FILE_PATH}"

  [ "${4}" ] && DES_P="${4}"
  [ -z "$DES_P" ] && DES_P="~/.ssh"

  echo "## 文件分发"
  KEY="${SRC_P}${SRC}"

  [ -e "$KEY" ] && [ -e "${KEY}.pub" ] && {
    echo "${SRC_P}${SRC} to $SSH_SERVER_USER@$SSH_SERVER_IP:${DES_P}/${DES} -p $SSH_SERVER_PORT"
    scp -i "${KEY}" "${SRC_P}${SRC}" $SSH_SERVER_USER@$SSH_SERVER_IP:${DES_P}/${DES} -p $SSH_SERVER_PORT ;
    scp -i "${KEY}" "${SRC_P}${SRC}.pub" $SSH_SERVER_USER@$SSH_SERVER_IP:${DES_P}/${DES}.pub -p $SSH_SERVER_PORT ;
  }
}
#ssh_all_key_scp_to_ms
#ssh_all_key_scp_to_ms "20-06-16" "20-06-16" "" ""
#ssh_all_key_scp_to_ms "20-06-16" "20-06-16" "" "~/.ssh/"

function scp_to_vm(){
  local SRC=
  local DES=
  local KEY=
  local SRC_P=
  local DES_P=
  [ "${1}" ] && SRC="${1}"
  [ -z "$SRC" ] && SRC="${PRIVITE_KEY_FILE_NAME}"
  [ "${2}" ] && DES="${2}"
  [ -z "$DES" ] && DES="${PRIVITE_KEY_FILE_NAME}"
  [ "${3}" ] && SRC_P="${3}"
  [ -z "$SRC_P" ] && SRC_P="${PRIVITE_KEY_FILE_PATH}"

  [ "${4}" ] && DES_P="${4}"
  [ -z "$DES_P" ] && DES_P="~/.ssh"

  echo "## 文件分发"
  KEY="${SRC_P}${SRC}"

  [ -e "$KEY" ] && {
    echo "${SRC_P}${SRC} to $SSH_SERVER_USER@$SSH_SERVER_IP:${DES_P}/${DES} -p $SSH_SERVER_PORT"
    scp -i "${KEY}" "${SRC_P}${SRC}" $SSH_SERVER_USER@$SSH_SERVER_IP:${DES_P}/${DES} -p $SSH_SERVER_PORT ;
  }
}
#scp_to_vm
#scp_to_vm  "20-06-16" "20-06-16" ~/.ssh/ "~/.ssh/"
#scp_to_vm  "20-06-16.pub" "20-06-16.pub" ~/.ssh/ "~/.ssh/"

function print_scp_to_vm(){
  local SRC=
  local DES=
  local KEY=
  local SRC_P=
  local DES_P=
  [ "${1}" ] && SRC="${1}"
  [ -z "$SRC" ] && SRC="${PRIVITE_KEY_FILE_NAME}"
  [ "${2}" ] && DES="${2}"
  [ -z "$DES" ] && DES="${PRIVITE_KEY_FILE_NAME}"
  [ "${3}" ] && SRC_P="${3}"
  [ -z "$SRC_P" ] && SRC_P="${PRIVITE_KEY_FILE_PATH}"

  [ "${4}" ] && DES_P="${4}"
  [ -z "$DES_P" ] && DES_P="~/.ssh"

  echo "## 文件分发"
  KEY="${SRC_P}${SRC}"

  [ -e "$KEY" ] && {
    #echo "${SRC_P}${SRC} to $SSH_SERVER_USER@$SSH_SERVER_IP:${DES_P}/${DES}"
    echo "scp -i \"${KEY}\" \"${SRC_P}${SRC}\" $SSH_SERVER_USER@$SSH_SERVER_IP:${DES_P}/${DES} -p $SSH_SERVER_PORT" ;
  }
}
#print_scp_to_vm
#print_scp_to_vm  "20-06-16" "20-06-16" ~/.ssh/ "~/.ssh/"
#print_scp_to_vm  "20-06-16.pub" "20-06-16.pub" ~/.ssh/ "~/.ssh/"

function ssh_config_file_add(){
  local key=
  local txt=
  local opt=
  local f=
  local tmp=
  [ "${1}" ] && opt="${1}"
  [ -z "$opt" ] && opt="github:add"
  [ "${2}" ] && f="${2}"
  [ -z "$f" ] && f=~/.ssh/config #diff with ~/.ssh/config

  tmp=~/.ssh/
  key=${PRIVITE_KEY_FILE_PATH}${PRIVITE_KEY_FILE_NAME}
  #echo "$PRIVITE_KEY_FILE_PATH,$tmp"
  [ _"$PRIVITE_KEY_FILE_PATH" = _"$tmp" ] && key="~/.ssh/${PRIVITE_KEY_FILE_NAME}"
  txt=$(cat <<EOF
Host github.com
    Hostname github.com
    User git
    IdentityFile $key
EOF
)
   echo "##配置文件"
   echo "#2 set host github,gitlab,gitee ... config in file ~/.ssh/config with key file $key"
  #[ _"$opt" = _"github:add" ] && echo "$txt" >>  "$f"
  #[ _"$opt" = _"github:del" ] && sed -i "/$txt/d" "$f"
  case _"$opt" in
    _"github:add")
        echo "$txt" >> "$f" ;;
    _"github:del")
    #sed   '/\[base\]/,/\[updates\]/{/\[base\]/!{/\[updates\]/!d}}' "$f";;
    #sed  '/Host github.com/,/    IdentityFile/{/Host github.com/!{/    IdentityFile/!d}}' "$f";; # 删除两个匹配模式之间内容（不含匹配模式这两行）
    start=$(echo "$txt"|sed -n "1p");
    sed  -i "/$start/,/IdentityFile/d" "$f" && sed -i "/^$/d" "$f";; # 删除两个匹配模式之间内容（含匹配模式）
    _"gitlab:add")
        echo "$txt" | sed "s/github.com/gitlab.com/g"  >> "$f" ;;
    _"gitlab:del")
        txt=$(echo "$txt" | sed "s/github.com/gitlab.com/g") ;
        start=$(echo "$txt"|sed -n "1p") ;
        sed  -i "/$start/,/IdentityFile/d" "$f" && sed -i "/^$/d" "$f";;
    _"gitee:add")
        echo "$txt" | sed "s/github.com/gitee.com/g"  >> "$f" ;;
    _"gitee:del")
        txt=$(echo "$txt" | sed "s/github.com/gitee.com/g") ;
        start=$(echo "$txt"|sed -n "1p") ;
        sed  -i "/$start/,/IdentityFile/d" "$f" && sed -i "/^$/d" "$f";;
    *)
       break ;;
  esac
  # gitlab tpl xx
 txt=$(cat <<EOF
  Host gitlab.com
    Hostname altssh.gitlab.com
    User git
    Port 443
    PreferredAuthentications publickey
    IdentityFile $key
EOF
)
}
# ssh_config_file_add
# ssh_config_file_add "github:add" ~/.ssh/config
#ssh_var_config "192.168.56.3" "root" "20-05-25" ~/.ssh/
#ssh_config_file_add "github:del" ./ssh_config
#ssh_config_file_add "github:add" ./ssh_config
#ssh_config_file_add "gitlab:del" ./ssh_config
#ssh_config_file_add "gitlab:add" ./ssh_config
#ssh_config_file_add "gitee:del" ./ssh_config
#ssh_config_file_add "gitee:add" ./ssh_config


var_list=$(cat<<EOF
$var_list
PRIVITE_KEY_FILE_NAME=
PRIVITE_KEY_FILE_PATH=
SSH_SERVER_IP=
SSH_SERVER_USER=
PUBLIC_KEY_FILE_NAME=
SSH_KEY_PASSPHRASE=
#key_name=
#txt=
#gitlab_url=
#gitlab_ssh_user=
#gitlab_ssh_port=
#gitlab_ssh_keyfile=
EOF
)
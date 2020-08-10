#!/bin/sh

THIS_FILE_PATH=$(cd $(dirname $0);pwd)
THIS_FILE_NAME=$(basename $0)
[ -z "$RUN_SCRIPT_PATH" ] && RUN_SCRIPT_PATH=$(pwd)

mod_require "sh-lib-gpg.sh" ;
mod_require "${SRC_PATH}/index.sh" ;

echo "todos:test.e2e"

# file usage
# test/e2e/entry02.sh
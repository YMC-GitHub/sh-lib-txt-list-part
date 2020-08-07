# sh lib txt-list-part
## desc

some function to curd txt-list-part for ymc shell lib

## deps

```sh
list=$(ls sh_modules) ; echo "$list" | sed "s/^ */- [x] /g"
list=$(ls sh_modules) ; echo "$list" | sed "s/^ */- [ ] /g"
```

### dev

- [ ] sh-lib-path-resolve.sh
- [x] sh-lib-project-dir-map.sh
- [x] sh-lib-load-lib.sh
- [ ] sh-lib-lang.sh
- [x] sh-lib-gpg.sh
- [x] sh-lib-ssh.sh

### tes

- [ ] sh-lib-path-resolve.sh
- [x] sh-lib-project-dir-map.sh
- [x] sh-lib-load-lib.sh
- [ ] sh-lib-lang.sh
- [ ] sh-lib-test.sh
- [ ] sh-lib-time-cost.sh

### pro

- [ ] sh-lib-gpg.sh
- [ ] sh-lib-lang.sh
- [ ] sh-lib-load-lib.sh
- [ ] sh-lib-path-resolve.sh
- [ ] sh-lib-project-dir-map.sh
- [ ] sh-lib-project-path-get.sh
- [ ] sh-lib-test.sh
- [ ] sh-lib-this-file.sh
- [ ] sh-lib-time-cost.sh
- [ ] sh-lib-txt-part.sh
- [ ] sh-lib-var-list.sh

### sam

- [ ] sh-lib-path-resolve.sh
- [x] sh-lib-project-dir-map.sh
- [x] sh-lib-load-lib.sh
- [ ] sh-lib-lang.sh


## apis

- [x] txt_list_part_get
- [x] txt_list_part_get2
- [x] txt_list_part_del2
- [x] txt_list_part_add3
- [x] txt_list_part_del3
- [x] txt_list_part_get3

```sh
cat src/index.sh |  grep "function " | sed "s/function */- [x] /g"  | sed "s/(.*) *{//g"
```

## feats

- [x] basic curd txt_list_part

## usage

### how to use for poduction?

```sh
# get the code

# run the index file
# ./src/index.sh

# or import to your sh file
# source /path/to/the/index file

# simple usage

```

### how to use for developer?

```sh
# get the code

# run test
# ./test/index.sh
#2 get some fail test
# ./test/index.sh | grep "it is false"
```

## author

yemiancheng <ymc.github@gmail.com>

## license

MIT

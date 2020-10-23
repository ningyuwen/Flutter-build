#!/usr/bin/env bash

echo "`pwd`"

file_path="`pwd`"

#string='My long string'
flutter_module="/girgir_flutter_module"

if [[ $file_path != *"$flutter_module"* ]]; then
  file_path=$file_path$flutter_module
  echo "$file_path"
  cd "$file_path"
fi

flutter build aar -v

# 打包完成复制aar到 native 的 im 模块

function readFile() {
  for file in `ls $1`
  do
    if [ -d $1"/"$file ]
    then
      readFile $1"/"$file
    else
#      echo $1"/"$file
#      file=$1
      if [ "${file##*.}"x = "aar"x ];then
        echo $1"/"$file
        cp -rf $1"/"$file "$file_path"/../business_module/im/libs
      fi
#      echo `basename $file`
   fi
  done
}

#函数定义结束，这里用来运行函数
folder="./build/host/outputs/repo"
readFile $folder

echo "Android build aar success and move aar success"
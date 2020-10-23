#!/usr/bin/env bash

flutter_path="`pwd`"

echo "flutter project path is: $flutter_path"

../../flutterw build aar -v

# 打包完成复制aar到 native 的 im 模块

mkdir aar

# 第26行设置需要move aar的路径 cp -rf $1"/"$file "$flutter_path"/../im/libs
# flutter_path为girgir_flutter_module路径

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
        cp -rf $1"/"$file "$flutter_path"/../im/libs
      fi
#      echo `basename $file`
   fi
  done
}

#函数定义结束，这里用来运行函数
folder="./build/host/outputs/repo"
readFile $folder

folder="./build/outputs/repo"
readFile $folder

echo "Android build aar success and move aar success"
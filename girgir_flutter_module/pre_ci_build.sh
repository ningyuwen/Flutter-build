#!/bin/bash

function init_flutter() {
   echo "[INFO]RUN : flutter packages get"
   [[ -f ".flutter/version" ]] && use_version=`cat $FLUTTER_DIR_NAME/version`
   [[ $use_version != $FLUTTER_VERSION ]] && ./flutterw version $FLUTTER_VERSION
   ./flutterw pub get
}

function copyFilesToAndroid() {
    echo "`date +"%T"` [INFO] pre_ci_build copyFilesToAndroid start"
    cp -rf AndroidFlutterConfig/build.gradle .android/
    cp -rf AndroidFlutterConfig/app/build.gradle .android/app/
    cp -rf AndroidFlutterConfig/include_flutter.groovy .android/
    cp -rf AndroidFlutterConfig/Flutter/build.gradle .android/Flutter/
    cp -rf AndroidFlutterConfig/settings.gradle .android/
    cp -rf AndroidFlutterConfig/app/AndroidManifest.xml .android/app/src/main/
    cp -rf AndroidFlutterConfig/app/MyApplication.kt .android/app/src/main/java/com/yy/mygirgir/girgir_im/host/
    echo "`date +"%T"` [INFO]: pre_ci_build copyFilesToAndroid end"
}

function copyCixFileToRootProject() {
    cp -rf AndroidFlutterConfig/cix/* ./
}

function ini_android() {
   echo "[INFO] init android copyCixFileToRootProject start"
   copyCixFileToRootProject
   echo "[INFO] init android copyCixFileToRootProject end"

   chmod -R 777 flutterw

   echo "[INFO] init android flutter env start"
   flutter_version_path="$ROOT_DIR/$FLUTTER_DIR_NAME"
   [[ -d $flutter_version_path ]] || flutter_version_path=$FLUTTER_HOME

   echo "`date +"%T"` [INFO]: pre_ci_build ini_android FLUTTER_HOME is: $FLUTTER_HOME"
   echo "`date +"%T"` [INFO]: pre_ci_build ini_android ANDROID_HOME is: $ANDROID_HOME"
   echo "`date +"%T"` [INFO]: pre_ci_build ini_android flutter_version_path is: $flutter_version_path"

   init_flutter

   copyFilesToAndroid

   echo "sdk.dir=$ANDROID_HOME"  > .android/local.properties
   echo "flutter.sdk=$flutter_version_path" >> .android/local.properties
   [[ -d "gradle" ]] || cp -r .android/gradle gradle
   [[ -f "gradle.properties" ]] || cp .android/gradle.properties gradle.properties

   echo "`date +"%T"` [INFO]: pre_ci_build ini_android build aar start"
   sh ./AndroidFlutterConfig/ci_android_build_aar.sh
   echo "`date +"%T"` [INFO]: pre_ci_build ini_android build aar end"

#   ./gradlew build publish
}

function ini_ios() {
   echo "[INFO] init ios flutter env"
   init_flutter

   #./flutterw build ios --no-codesign
}

ROOT_DIR="`pwd -P`"
FLUTTER_DIR_NAME='.flutter'
FLUTTER_VERSION=1.9.1+hotfix.6

if [ -z $1 ];then
   ini_ios
else
   ini_$1

fi

#ini_android
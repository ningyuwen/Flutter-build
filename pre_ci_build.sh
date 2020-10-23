
#!/bin/bash

ROOT_DIR="`pwd -P`"
FLUTTER_DIR_NAME='.flutter'
FLUTTER_VERSION=1.9.1+hotfix.2

echo "`date +"%T"` [INFO]: pre_ci_build flutter wrapper install start"
curl -sL https://git.yy.com/ci_team/flutter_wrapper/raw/master/install.sh | bash -
echo "`date +"%T"` [INFO]: pre_ci_build flutter wrapper install finish"

echo "`date +"%T"` [INFO]: pre_ci_build git clone girgir_flutter_module start"
git clone https://git.yy.com/apps/yyflutter/girgir_flutter_module.git
ls girgir_flutter_module
echo "`date +"%T"` [INFO]: pre_ci_build git clone girgir_flutter_module end"

function init_flutter() {
   echo "`date +"%T"` [INFO]: pre_ci_build init_flutter start"
   echo $(pwd)
   [[ -f ".flutter/version" ]] && use_version=`cat $FLUTTER_DIR_NAME/version`
   [[ $use_version != $FLUTTER_VERSION ]] && ../flutterw version $FLUTTER_VERSION
   printf "`date +"%T"` pre_ci_build init_flutter use_version: $use_version\n"
   ../flutterw pub get
   echo "`date +"%T"` [INFO]: pre_ci_build init_flutter end"
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

function buildAarAndCopyToIM() {
    echo "`date +"%T"` [INFO]: pre_ci_build buildAarAndCopyToIM start"
    echo $(pwd)
    sh AndroidFlutterConfig/ci_android_build_aar.sh
    echo "`date +"%T"` [INFO]: pre_ci_build buildAarAndCopyToIM end"
}

function ini_android() {
   echo "`date +"%T"` [INFO]: pre_ci_build init android flutter env start"

   echo $(pwd)
   flutter_version_path="$ROOT_DIR/$FLUTTER_DIR_NAME"
   [[ -d $flutter_version_path ]] || flutter_version_path=$FLUTTER_HOME

   echo "`date +"%T"` [INFO]: pre_ci_build ini_android FLUTTER_HOME is: $FLUTTER_HOME"
   echo "`date +"%T"` [INFO]: pre_ci_build ini_android ANDROID_HOME is: $ANDROID_HOME"
   echo "`date +"%T"` [INFO]: pre_ci_build ini_android flutter_version_path is: $flutter_version_path"

   echo "sdk.dir=$ANDROID_HOME"  > ./local.properties
   echo "flutter.sdk=$flutter_version_path" >> ./local.properties

   cd girgir_flutter_module
   echo $(pwd)

   init_flutter

   copyFilesToAndroid

   buildAarAndCopyToIM

   echo "`date +"%T"` [INFO]: pre_ci_build init android flutter env end"
}

function ini_ios() {
   echo "`date +"%T"` [INFO] init ios flutter env start"
   init_flutter
}

ini_android

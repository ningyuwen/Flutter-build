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

flutter pub get

cp -rf AndroidFlutterConfig/build.gradle .android/
cp -rf AndroidFlutterConfig/app/build.gradle .android/app/
cp -rf AndroidFlutterConfig/include_flutter.groovy .android/
cp -rf AndroidFlutterConfig/Flutter/build.gradle .android/Flutter/
cp -rf AndroidFlutterConfig/settings.gradle .android/
cp -rf AndroidFlutterConfig/app/AndroidManifest.xml .android/app/src/main/
cp -rf AndroidFlutterConfig/app/MyApplication.kt .android/app/src/main/java/com/yy/mygirgir/girgir_im/host/

#flutter build ios --no-codesign

#flutter build apk
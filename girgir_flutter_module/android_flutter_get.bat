
call set var=%cd%
call echo %var%

call set girgir_flutter_module=girgir_flutter_module

call set flutter_module=%var%\%girgir_flutter_module%
call echo %flutter_module%

call pushd %flutter_module%

call echo %cd%

call flutter pub get

call xcopy AndroidFlutterConfig\build.gradle .android\ /y
call xcopy AndroidFlutterConfig\app\build.gradle .android\app\ /y
call xcopy AndroidFlutterConfig\include_flutter.groovy .android\ /y
call xcopy AndroidFlutterConfig\Flutter\build.gradle .android\Flutter\ /y
call xcopy AndroidFlutterConfig\settings.gradle .android\ /y
call xcopy AndroidFlutterConfig\app\AndroidManifest.xml .android\app\src\main\ /y
call xcopy AndroidFlutterConfig\app\MyApplication.kt .android\app\src\main\java\com\yy\mygirgir\girgir_im\host\ /y

call echo %cd%
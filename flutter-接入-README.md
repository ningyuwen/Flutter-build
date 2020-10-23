## 原生Android接入Flutter

https://docs.qq.com/doc/DWEtVSHBZeVZNcklz

## GirGir接入Flutter

接入方式分为源码集成和产物集成两种，下面的介绍是接入之前的一些步骤及接入方式：

前置步骤：

```     Java
// Android项目
git clone https://git.yy.com/apps/girgir/girgir-android.git
git submodule init
git submodule update
cd girgir_flutter_module
flutter packages get

// girgir-android/settings.gradle
setBinding(new Binding([gradle: this]))
evaluate(new File(settingsDir.absolutePath, 'girgir_flutter_module/.android/include_flutter.groovy'))
```

* 源码集成

    ```     Java
    // girgir-android/settings.gradle
    # 由于中间件会给每个module生成api包，但是以下module不应生成api包，使用"athenaExclude"排除
    startParameter.projectProperties.put("athenaExclude", ['flutter',
                                                            'sentry_plugin',
                                                            'shared_preferences',
                                                            'flutter_service',
                                                            'yynativehelper',
                                                            'flutter_hummer',
                                                            'sqflite',
                                                            'path_provider',
                                                            'flutter_orm_plugin',
                                                            'flutter_luakit_plugin'])

    // girgir-android/business_module/im/build.gradle
    dependencies {
        ...
        implementation project(':flutter')
    }    
    ```

* 产物集成

    ```     Java
    // girgir-android/business_module/im/build.gradle
    dependencies {
        ...
        // 包含了flutter build aar生成的所有aar包，如下图所示
        implementation fileTree(dir: 'libs', include: ['*.jar', '*.aar'])
    }
    ```

## GirGir通用配置

```     Java
// girgir-android/gradle.properties
# true：源码集成
# false：产物集成
##################################################################
android_enableDetectFlutterDir=true        
##################################################################

// girgir-android/settings.gradle
setBinding(new Binding([gradle: this]))
evaluate(new File(settingsDir.absolutePath, 'include_flutter.groovy'))

// girgir-android/include_flutter.groovy
# include_flutter.groovy脚本所执行任务如下：
# 1. 检测Flutter项目是否存在；
# 2. 运行flutter packages get；
# 3. 添加Flutter项目下Android原生工程所需依赖。
# 内容请参看如下链接：
https://git.yy.com/apps/girgir/girgir-android/blob/girgir-android_flutter_feature/include_flutter.groovy

// girgir-android/business_module/im/build.gradle
dependencies {
    ...
    // isDetectedFlutterDir是girgir-android/include_flutter.groovy定义的变量，意为是否使用Flutter开发
    if (gradle.isDetectedFlutterDir) {
        println "[INFO]: developedWithFlutter is true"
        implementation project(':flutter')
    } else {
        // 换成自己的flutter产物
        println "[INFO]: developedWithFlutter is false"
        implementation fileTree(dir: 'libs', include: ['*.jar', '*.aar'])
    }
}
```
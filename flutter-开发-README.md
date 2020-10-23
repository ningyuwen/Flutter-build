# Flutter开发相关知识

本文档是学习Flutter相关知识的记录。

# FlutterView

Android这边Flutter有两个版本的FlutterView，它们分别在io.flutter.view（下面简写1版） 和 io.flutter.embedding.android（2版）包中，它们的区别如下：
1. 1版继承了SurfaceView，2版继承FrameLayout，可以指定FlutterView类型为TextureView、SurfaceView
1. 1版中包含了FlutterEngine（FlutterNativeView），2版需要开发者自行创建FlutterEngine
1. 1版FlutterView中包含很多MethodChannel，2版将1版的MethodChannel移到了FlutterEngine中
1. 1版在单FlutterView的情况下更具优势，无需切换Engine与FlutterView的绑定关系就能显示所有Flutter页面
1. 2版在多FlutterView的情况下更具优势，多FlutterView的场景又在混合开发时才会遇到，使用方法是：单FlutterEngine，多FlutterView
1. 综上，两个不同版本的使用场景为：1版适用于纯Flutter开发，2版适用于混合开发

# FlutterEngine

FlutterEngine是控制渲染的，渲染完成后显示在FlutterView上，一个FlutterEngine同时只能绑定一个FlutterView。

所以App首页这种使用ViewPager加载多个Fragment，且每个Fragment包含了一个FlutterView的情况可以在setUserVisibleHint()方法中切换FlutterEngine与FlutterView的绑定。

# MethodChannel

方法通道，用于Flutter、Native之间通信，由于MethodChannel是绑定到FlutterEngine的，所以尽量避免在生命周期方法中将MethodChannel置为null，会收不到消息。

# FlutterEngine初始化

```     Java
// 初始化Flutter环境
FlutterMain.startInitialization(RuntimeInfo.sAppContext)
FlutterMain.ensureInitializationComplete(RuntimeInfo.sAppContext, null)

// 初始化FlutterEngine
flutterEngine = FlutterEngine(RuntimeInfo.sAppContext)
flutterEngine?.dartExecutor?.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
flutterEngine?.navigationChannel?.setInitialRoute("/")
```

# FlutterView初始化

```     Java
// 初始化FlutterView
flutterView = FlutterView(
    RuntimeInfo.sAppContext,
    FlutterView.RenderMode.surface,
    FlutterView.TransparencyMode.transparent
)

// FlutterView绑定FlutterEngine
flutterView?.attachToFlutterEngine(flutterEngine!!)
```

# Flutter项目依赖的插件初始化

```     Java
// 设置方法通道，用于Flutter、Native之间通信
GeneratedPluginRegistrant.registerWith(ShimPluginRegistry(flutterEngine!!))
```

# Flutter项目接入插件失败原因
1. androidX，需要将androidX依赖改为老版的Android依赖，对照表如下：https://blog.csdn.net/qq_35605213/article/details/99305921, Maven仓库地址：https://mvnrepository.com/

1. 插件中调用registrar.view()，用于获取FlutterView，此方法在使用io.flutter.view包的FlutterView可以正常运行，在使用io.flutter.embedding.android包中的FlutterView会抛出异常：
    ```     Java
    public FlutterView view() {
        throw new UnsupportedOperationException("The new embedding does not support the old FlutterView.");
    }
    ```

1. 插件中调用registrar.activity()，空指针异常，由于io.flutter.view中FlutterView是纯Flutter项目开发使用的，通过FlutterView可以获取到当前绑定的Activity。
而io.flutter.embedding.android中的FlutterView没有绑定当前的Activity，所以在某些插件使用当前绑定的Activity时会空指针异常，解决方法是：
    ```     Java
    flutterEngine?.activityControlSurface?.attachToActivity(activity, lifecycle)
    ```

1. PlatformViewsChannel报错未实现其中的方法通道，原因：io.flutter.embedding.android包中的FlutterView未调用PlatformViewsController.java类的attach()方法，解决方法：
    ```     Java
    方法一：
    flutterEngine?.platformViewsController?.attach(RuntimeInfo.sAppContext, flutterEngine?.renderer, flutterEngine?.dartExecutor!!)

    方法二：
    //attachToActivity()方法会调用platformViewsController的attach()方法
    flutterEngine?.activityControlSurface?.attachToActivity(activity, lifecycle)
    ```

1. Flutter-boost接入的情况下接入image-picker等需要Activity回调的插件报错，例如此issue：https://github.com/alibaba/flutter_boost/issues/263，
    
    原因：Flutter-boost在初始化时一并初始化了每个插件，而Flutter-boost的初始化一般是在Application中，这就导致了当前传入Flutter的PluginRegister中的Activity都是SplashActivity，
而在权限请求、相机拍照等需要回调onActivityResult()方法的，会接收不到回调，因为此时显示在用户眼前的是BoostFlutterActivity，只有在BoostFlutterActivity的onActivityResult()方法
接收到回调，才会调用到每个插件注册的onActivityResult();
    
    解决办法：image-picker插件初始化时传入的context，获取applicationContext，并监听每个Activity的创建，在BoostFlutterActivity创建时，才注册image-picker插件。
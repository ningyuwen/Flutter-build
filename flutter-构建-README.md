# Flutter 构建

Flutter项目构建文档，包含Flutter、Native混合构建，纯Flutter项目单独构建

# 混合构建

* 混合构建可以线上构建，也可本地构建

脚本执行的步骤：
1. 在Flutter项目中执行flutter build aar
1. 将aar产物复制到Native项目libs文件夹下
1. Native项目依赖libs文件夹下的aar
1. 编译Native项目

* `Flutter、Native混合构建（线上构建，本地构建）可参考分支：Flutter_build_混合构建`

注意事项：
1. Flutter线上构建速度非常缓慢，需要经历下载Flutter wrapper，下载插件代码，下载各插件依赖的包等过程
1. 本地构建，并复制到Native项目，可执行girgir_flutter_module下的 android_build_aar.sh 脚本，由于本地有缓存，构建速度会快很多

# 纯Flutter构建

* 纯Flutter构建主要为线上构建，并发布aar到公司Maven仓库

前置步骤：
1. 公司Cix系统创建项目（Cross、lib）
1. 为Flutter项目配置Flutter wrapper环境(参考链接：http://doc.yypm.com/pages/viewpage.action?pageId=51871752)
1. 添加构建系统对Flutter构建需要的前置脚本：pre_ci_build.sh，并指定FLUTTER_VERSION版本
1. 添加发布aar脚本：publish_common.gradle，并指定其中的group、version版本号

脚本执行的步骤：
1. 下载Flutter wrapper
1. 执行flutter pub get命令
1. 执行flutter build aar命令，拷贝打包好的aar产物到girgir_flutter_module目录下的aar文件夹，有多少个插件就有多少个aar
1. 执行publish_common.gradle脚本，将aar发布到Maven仓库

* `纯Flutter构建（线上构建）可参考分支：Flutter_build_纯Flutter构建`

注意事项：
1. 纯Flutter线上构建由于需要下载Flutter wrapper，各Flutter插件代码，且无缓存，所以编译时间很长，大概十分钟左右
1. 线上构建之前需要修改publish_common.gradle中的version版本号
1. aar构建完成查看地址：http://repo.yypm.com:8181/nexus/#welcome
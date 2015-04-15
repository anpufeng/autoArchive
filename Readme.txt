通过命令行自动打包

 参数说明
-e environment环境， 必选参数(PRD, STG1, STG2): 例 -e PRD
-i identifier bundle id， 必选参数: 例 -i com.xxxx.yyyy
-b build id， 必选参数: 例  -b 88
-s Sign证书签名， 必选参数:  -s iPhone Developer: pin\ lin (VQ873F9G68), 因为终端问题 空格 括号等特殊字符要加\转义字符
-p provisioning文件， 必选参数: 例 -p 416c0c06-0fbc-48a2-845c-58b68f05d2ce
-v version版本， 必选参数: 例 -v 88
-f plist文件， 必选参数: 例 -f HM-HEALTH-Info.plist
-t target name 工程名， 必选参数: 例 -t HM-HEALTH
-d directory 工程文件所在目录 默认为取当前目录， 可选参数:
-o output 输出目录 默认桌面路径 ~/Desktop/output， 可选参数:
-c configuration (Release|Debug) 默认为Release， 可选参数:
-a architecture armv7, armv7s, arm64 3选1 默认为armv7 arm64两种架构 可选参数
-k sdk， 默认为 iphoneos8.1 可选参数

将此文件放至与工程文件.xcodeproj同一目录  然后运行以下命令， -s -p 对应参数为使用者电脑上对应的证书签名(目前-e参数还未支持， 需手动修改)

示例如下   注意证书文件的空格括号等特殊符号要加上转义字符 不然不识别
///DEBUG
./AutoArchiveObjc -t YOUR-TARGET -b 99 -e PRD -f  YOURPROJECT-Info.plist -i com.bundleid.dev -s iPhone\ Developer:\ Jialun\ Wu\ \(N688KD9E9P\) -p e3fdd5ab-64b8-4e4f-9e8f-b46c36ffc993 -v 1.9.0 -d /Users/sss/Documents/archive/YOURPROJECT -c Debug

///RELEASE
./AutoArchiveObjc -t YOUR-TARGET -b 99 -e PRD -f  YOURPROJECT-Info.plist -i com.bundleid.prd -s iPhone\ Distribution:\ Ltd. -p 09bb858c-b7f2-4f78-8d77-235063659fbb -v 1.9.0 -d /Users/sss/Documents/archive/YOURPROJECT -c Release
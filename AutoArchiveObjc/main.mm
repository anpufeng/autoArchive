//
//  main.cpp
//  AutoArchive
//
//  Created by sss on 14/12/4.
//  Copyright (c) 2014年 ethan. All rights reserved.
//
// @author ethan


#import <Foundation/Foundation.h>
#include <iostream>
#include <stdlib.h>
#include <map>
#include <stdio.h>
#include <string>
#include <unistd.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>

using namespace std;

map<string, string> params;
static const string empty_param = "empty";

//com.ehis.healthpush
NSString *key_identifier = @"CFBundleIdentifier";
//1.3.3
NSString *key_version = @"CFBundleShortVersionString";
//63
NSString *key_build = @"CFBundleVersion";

///改变环境配置头文件
NSString *env_header = @"YLUrls.h";

void str_replace(string &strBase, string strSrc, string strDes)
{
    string::size_type pos = 0;
    string::size_type srcLen = strSrc.size();
    string::size_type desLen = strDes.size();
    pos=strBase.find(strSrc, pos);
    while ((pos != string::npos))
    {
        strBase.replace(pos, srcLen, strDes);
        pos=strBase.find(strSrc, (pos + desLen));
    }
}


///使用帮助
void print_help(const string &app) {
    printf("#error 参数出错, 使用方法: \n");
    printf("-e environment环境， 必选参数(PRD, STG1, STG2): 例 -e PRD \n");
    printf("-i identifier bundle id， 必选参数: 例 -i com.xxxx.yyyy \n");
    printf("-b build id， 必选参数: 例  -b 88\n");
    printf("-s Sign证书签名， 必选参数:  -s iPhone Developer: pin\\ lin (VQ873F9G68), 因为终端问题 空格 括号等特殊字符要加\\转义字符\n");
    printf("-p provisioning文件， 必选参数: 例 -p 416c0c06-0fbc-48a2-845c-58b68f05d2ce\n");
    printf("-v version版本， 必选参数: 例 -v 88\n");
    printf("-f plist文件， 必选参数: 例 -f HM-HEALTH-Info.plist \n");
    printf("-t target name 工程名， 必选参数: 例 -t HM-HEALTH\n");
    printf("-d directory 工程文件所在目录 默认为取当前目录， 可选参数: \n");
    printf("-o output 输出目录 默认桌面路径 ~/Desktop/output， 可选参数: \n");
    printf("-c configuration (Release|Debug) 默认为Release， 可选参数: \n");
    printf("-a architecture armv7, armv7s, arm64 3选1 默认为armv7 arm64两种架构 可选参数\n");
    printf("-k sdk， 默认为 iphoneos8.1 可选参数\n");
    
    printf("使用示例  -t HM-HEALTH -b 99 -e stg -f HM-HEALTH-Info.plist -i com.ehis.healthpush -s iPhone Developer: pin lin (VQ873F9G68) -p 416c0c06-0fbc-48a2-845c-58b68f05d2ce -v 1.9.0 -d /Users/sss/Documents/hmhealth/1130/HM-HEALTH -c Debug\n");
    exit(1);
}

///校验是否使用默认值
inline bool check_default(const string &param) {
    return empty_param == params[param];
}

inline void system_cmd(const string &cmd) {
    printf("\n");
    int result = system(cmd.c_str());
    if (result == 0) {
        printf("执行命令完毕 : %s\n", cmd.c_str());
    } else {
        printf("执行命令出错 : %s\n", cmd.c_str());
        exit(1);
    }
}

///根据参数修改打包配置, 如CFBundleVersion, CFBundleIdentifier
void fix() {
    NSFileManager *manager = [NSFileManager defaultManager];
    //NSString *target = [NSString stringWithUTF8String:params["t"].c_str()];
    //NSString *file = [NSString stringWithUTF8String:params["f"].c_str()];
    NSString *target = [[NSString alloc] initWithCString:params["t"].c_str() encoding:NSUTF8StringEncoding];
    NSString *file = [[NSString alloc] initWithCString:params["f"].c_str() encoding:NSUTF8StringEncoding];
    
    NSString *current = [manager currentDirectoryPath];
    if (check_default("d")) {
        
    } else {
        current = [[NSString alloc] initWithCString:params["d"].c_str() encoding:NSUTF8StringEncoding];
    }

    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", current, target, file];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    NSString *new_identifier = [NSString stringWithUTF8String:params["i"].c_str()];
    NSString *new_build = [NSString stringWithUTF8String:params["b"].c_str()];
    NSString *new_version = [NSString stringWithUTF8String:params["v"].c_str()];
    
    dic[key_identifier] = new_identifier;
    dic[key_version] = new_version;
    dic[key_build] = new_build;
    if ([dic writeToFile:path atomically:YES]) {
        NSLog(@"修改并写入plist成功");
        NSLog(@"file url: %@, item : %@",path, dic);
    } else {
        NSLog(@"#error 修改并写入plist失败 目录 ： %@ dic: %@", path, dic);
        exit(1);
    }
    
    NSLog(@"开始修改环境 YLUrl.h   TODO!!!!!!!!!!!!!");
    
    NSString *evn = [NSString stringWithUTF8String:params["e"].c_str()];
    if ([evn isEqualToString:@"PRD"] || [evn isEqualToString:@"STG1"] || [evn isEqualToString:@"STG2"]) {
        NSString *before = @"#define ENVIRENTMENT_LOGIN  PRD";
        NSString *after = [NSString stringWithFormat:@"#define ENVIRENTMENT_LOGIN  %@", evn];
    } else {
        NSLog(@"服务器环境参数错误! 使用方法 -e environment环境， 必选参数(PRD, STG1, STG2): 例 -e PRD");
        exit(1);
    }
}


///检查环境 如BUILD ID, bundle id, 环境配置
void param_check(int argc, char **argv, map<string, string> &params) {
    int ch;
    opterr = 0;
    
    while((ch = getopt(argc, argv, "e:i:b:s:p:v:f:t:d::o::c::a::k::")) != -1) {
        switch(ch) {
            case 'e': case 'i': case 'b': case 's': case 'p':
            case 'v': case 'f': case 't': case 'd': case 'o':
            case 'c': case 'a': case 'k':
                
                char str[4];
                sprintf(str, "%c", ch);
                //printf("%-30s: '%-60s\n", params[str].c_str(), optarg);
                printf("%-10s: '%-60s\n", str , optarg);
                params[str] = optarg;
                
                break;
           
            default:
                print_help(string(argv[0]));
                break;
        }
    }
    
    map<string, string>::iterator it;
    for(it = params.begin(); it != params.end(); ++it) {
        if (check_default(it->first.c_str())) {
            if (it->first == "e" ||
                it->first == "i" ||
                it->first == "b" ||
                it->first == "s" ||
                it->first == "p" ||
                it->first == "v" ||
                it->first == "f" ||
                it->first == "t") {
                printf("#error 参数错误 %s\n", it->first.c_str());
                print_help(string(argv[0]));
            }
        }
    }

}


///编译, 开始执行xcodebuild
void xbuild() {
    string path;
    if (check_default("d")) {
        char *buffer;
        //也可以将buffer作为输出参数
        if((buffer = getcwd(NULL, 0)) == NULL) {
            perror("getcwd error");
            exit(1);
        } else {
            printf("无指定工程目录 默认取当前目录: %s\n", buffer);
            path = string(buffer);
            params["d"] = path;
            free(buffer);
        }
    } else {
        path = params["d"];
    }
    
    if (chdir(path.c_str()) < 0) {
        printf("chdir %s", strerror(errno));
        exit(1);
    }
    
    string build = "xcodebuild -target ";
    build += params["t"];
    if (!check_default("c")) {
        build += " -configuration ";
        build += params["c"];
    }
    
    build += " clean";
    
    
    printf("开始执行打包前工程清理... \n%s\n", build.c_str());
    system_cmd(build.c_str());
    printf("清理完毕\n");
    
    //CODE_SIGN_IDENTITY
    build = "xcodebuild -target ";
    build += params["t"];
    build += " CODE_SIGN_IDENTITY=\"";
    build += params["s"];
    build += "\"";
    
    //PROVISIONING_PROFILE
    build += " PROVISIONING_PROFILE=";
    build += params["p"];
    
    //一些可选参数
    if (check_default("c")) {
        build += " -configuration Release";
    } else {
        build += " -configuration ";
        build += params["c"];
    }
    
    if (check_default("a")) {
         build += " ARCHS='armv7 arm64'";
    } else {
        build += " -arch ";
        build += params["a"];
    }
    
    if (check_default("k")) {
        build += " -sdk iphoneos8.1";
    } else {
        build += " -sdk ";
        build += params["k"];
    }
    
    printf("开始执行编译...\n %s\n", build.c_str());
    system_cmd(build.c_str());
    printf("编译成功完毕\n");
}

///打包 开始执行xrun
void archive() {
    string archive = "xcrun";
    string app_path = "/build";

    string ipa_path;
    string ipa_name;
    if (check_default("c")) {
        app_path += "/Release-iphoneos/";
        
    } else {
        app_path += "/";
        app_path += params["c"];
        app_path += "-iphoneos/";
    }
    app_path += params["t"];
    app_path += ".app";

    if (check_default("o")) {
        ipa_path += "~/Desktop";
        ipa_path += "/output";
    } else {
        ipa_path = params["o"];
    }
    
    char create[100];
    sprintf(create, "mkdir %s", ipa_path.c_str());
    system(create);
    
    time_t t = time(0);
    char tmp[4];
    strftime(tmp, sizeof(tmp), "%m/%d", localtime(&t) );
    
    ipa_name += params["t"];
    ipa_name += "_";
    ipa_name += params["e"];
    ipa_name += "_";
    ipa_name += params["b"];
    ipa_name += "_";
    ipa_name += params["v"];
    ipa_name += ".ipa";
    
    ipa_path += "/";
    ipa_path += ipa_name;
    
    if (check_default("k")) {
        archive += " -sdk iphoneos8.1";
    } else {
        archive += " -sdk ";
        archive += params["k"];
    }
    archive += " PackageApplication";
    archive += " -v ";
    archive += params["d"];
    archive += app_path;
    archive += " -o ";
    archive += ipa_path;

    archive += " --sign \"";
    archive += params["s"];
    archive += "\"";

    //xcrun -sdk iphoneos PackageApplication -v 源app路径 -o 输出的ipa路径 --sign "iPhone Distribution:XXXXXX

    printf("开始执行打包...\n %s\n", archive.c_str());
    system_cmd(archive.c_str());
    printf("执行打包成功完毕 恭喜\n");
    
    string dsym;
    dsym += "cp -R ";
    dsym += params["d"];
    dsym += app_path;
    dsym += ".dSYM ";
    str_replace(ipa_path, "ipa", "app");
    dsym += ipa_path;
    dsym += ".dSYM";
    printf("开始移动dSYM文件...\n %s\n", dsym.c_str());
    system_cmd(dsym.c_str());
    printf("移动dSYM文件完毕...\n \n");
    
    string move_app;
    move_app += "cp -R";
    move_app += " ";
    move_app += params["d"];
    move_app += app_path;
    move_app += " ";
    str_replace(ipa_path, "ipa", "app");
    move_app += ipa_path;
    
    printf("开始移动app文件...\n %s\n", move_app.c_str());
    system_cmd(move_app.c_str());
    printf("移动app文件文件完毕...\n \n");
}


int main(int argc, char **argv) {
    // insert code here...
    
    @autoreleasepool {
        // insert code here...
        params["e"] = empty_param;
        params["i"] = empty_param;
        params["b"] = empty_param;
        params["s"] = empty_param;
        params["p"] = empty_param;
        params["v"] = empty_param;
        params["f"] = empty_param;
        params["t"] = empty_param;
        
        //后面为可选参数
        params["d"] = empty_param;
        params["o"] = empty_param;
        params["c"] = empty_param;
        params["a"] = empty_param;
        params["k"] = empty_param;
        param_check(argc, argv, params);
        fix();
        xbuild();
        archive();
    }
    
        return 0;
}


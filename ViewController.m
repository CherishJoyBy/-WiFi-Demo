//
//  ViewController.m
//  跳转WiFi设置Demo
//
//  Created by lby on 17/3/30.
//  Copyright © 2017年 lby. All rights reserved.
//

#import "ViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>
#import <dlfcn.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)jumpToWiFi
{
    // iOS10只能打开设置界面,iOS9.1可以打开WiFi界面
    [self openSystemSetting:@"无线局域网"];
    
//    NSLog(@"%@",[self getCurrentWifiName]);
//    NSLog(@"%@",[self getLocalWiFiIPAddress]);
    
//    [self openScheme:@"App-Prefs:root=WIFI"];
}

// 打开设置的WiF(iOS10可用)
- (void)openScheme:(NSString *)scheme
{
    UIApplication *application = [UIApplication sharedApplication];
    
    NSURL *URL = [NSURL URLWithString:scheme];
    
    if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        
        [application openURL:URL options:@{}
         
           completionHandler:^(BOOL success) {
               
               NSLog(@"Open %@: %d",scheme,success);
               
           }];
        
    } else {
        
        BOOL success = [application openURL:URL];
        
        NSLog(@"Open %@: %d",scheme,success);
    }
}

// 打开app的设置界面
- (void)openSystemSetting:(NSString *)settingName
{
    //iOS8 才有效
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
#define SETTING_URL @"app-settings:"
#else
#define SETTING_URL   UIApplicationOpenSettingsURLString
#endif
    if (version >= 8.0){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:SETTING_URL] options:@{} completionHandler:nil];
    }
}

/**
 获取当前Wifi地址

 @return WifiIP地址
 */
- (NSString *)getLocalWiFiIPAddress
{
    BOOL success;
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;
    
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            // the second test keeps from picking up the loopback address
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if ([name isEqualToString:@"en0"])  // Wi-Fi adapter
                    return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return nil;
}

/**
 获取当前Wifi名称(上架不可行,需要使用<NetworkExtension/NetworkExtension.h>框架 )

 @return Wifi名称
 */
- (NSString *)getCurrentWifiName
{
#if TARGET_OS_SIMULATOR
    return @"(simulator)";
#else
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
    
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) {
            break;
        }
    }
    NSDictionary *dctySSID = (NSDictionary *)info;
    NSString *ssid = [dctySSID objectForKey:@"SSID"] ;
    
    return ssid;
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

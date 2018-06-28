//
//  fitpolo701LogManager.h
//  testSDK
//
//  Created by aa on 2018/3/14.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, fitpolo701DataDirection) {
    fitpolo701DataSourceAPP,          //来自于app-->device的数据
    fitpolo701DataSourceDevice,       //来自于device-->app的数据，
};

@interface fitpolo701LogManager : NSObject

/**
 写入命令到本地文件,本地目前只保留一周的数据
 
 @param dataList 要写入的数据，可以写入一系列的数据，数组里面必须是字符串
 @param source app-->device或者是device-->app
 */
+ (void)writeCommandToLocalFile:(NSArray *)dataList
                 withSourceInfo:(fitpolo701DataDirection )source;

/**
 读取本地存储的命令数据
 
 @return 存储的命令数据
 */
+ (NSData *)readCommandDataFromLocalFile;

@end

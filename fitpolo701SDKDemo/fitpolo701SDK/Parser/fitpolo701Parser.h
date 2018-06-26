//
//  fitpolo701Parser.h
//  testSDK
//
//  Created by aa on 2018/3/13.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "fitpolo701AlarmClockModel.h"
#import "fitpolo701EnumerateDefine.h"
#import "fitpolo701TaskIDDefines.h"

@class fitpolo701AncsModel;
@class fitpolo701ScreenDisplayModel;
@class fitpolo701ScanModel;
@interface fitpolo701Parser : NSObject

+ (NSInteger)getDecimalWithHex:(NSString *)content range:(NSRange)range;
+ (NSString *)getDecimalStringWithHex:(NSString *)content range:(NSRange)range;
+ (NSArray *)interceptionOfArray:(NSArray *)originalArray subRange:(NSRange)range;
+ (NSData *)getCrc16VerifyCode:(NSData *)data;
+ (NSString *)getAncsCommand:(fitpolo701AncsModel *)ancsModel;
+ (fitpolo701AncsModel *)getAncsOptions:(NSString *)content;
+ (NSString *)getAlarmClockType:(fitpolo701AlarmClockType)clockType;
+ (NSString *)getAlarlClockSetInfo:(fitpolo701StatusModel *)statusModel isOn:(BOOL)isOn;
+ (NSString *)getHeartRateAcquisitionInterval:(fitpolo701HeartRateAcquisitionInterval)intervalType;
+ (NSString *)getScreenDisplay:(fitpolo701ScreenDisplayModel *)displayModel;
+ (NSString *)hexStringFromData:(NSData *)sourceData;
+ (NSString *)getTimeStringWithDate:(NSDate *)date;
+ (NSString *)getCommandType:(fitpolo701TaskOperationID)operationID;
+ (NSData *)stringToData:(NSString *)dataString;
+ (BOOL)isMacAddress:(NSString *)macAddress;
+ (BOOL)isMacAddressLowFour:(NSString *)lowFour;
+ (BOOL)isUUIDString:(NSString *)uuid;
+ (NSDictionary *)getHardwareParameters:(NSString *)content;
+ (NSDictionary *)getMemoryData:(NSString *)content;
+ (NSDictionary *)getStepData:(NSString *)content;
+ (NSDictionary *)getSleepIndexData:(NSString *)content;
+ (NSDictionary *)getSleepRecordData:(NSString *)content;
+ (NSArray *)getHeartRateData:(NSString *)content;
+ (NSDictionary *)getFirmwareVersion:(NSString *)content;
+ (NSArray *)getAlarmClockList:(NSString *)content;
+ (NSArray *)getSleepDataList:(NSArray *)indexList recordList:(NSArray *)recordList;
+ (fitpolo701ScanModel *)getModelWithParamDic:(NSDictionary *)paramDic peripheral:(CBPeripheral *)peripheral;
+ (NSDictionary *)getSedentaryRemindData:(NSString *)content;
+ (NSDictionary *)getConfigurationParameters:(NSString *)content;

@end

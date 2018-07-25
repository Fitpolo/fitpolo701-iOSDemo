//
//  fitpolo701Parser.h
//  testSDK
//
//  Created by aa on 2018/3/13.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "fitpolo701TaskIDDefines.h"
#import "fitpolo701Models.h"

/*
 自定义的错误码
 */
typedef NS_ENUM(NSInteger, fitpolo701CustomErrorCode){
    fitpolo701BlueDisable = -10000,                                     //当前手机蓝牙不可用
    fitpolo701ConnectedFailed = -10001,                                 //连接外设失败
    fitpolo701PeripheralDisconnected = -10002,                          //当前外部连接的设备处于断开状态
    fitpolo701CharacteristicError = -10003,                             //特征为空
    fitpolo701RequestPeripheralDataError = -10004,                      //请求手环数据出错
    fitpolo701ParamsError = -10005,                                     //输入的参数有误
    fitpolo701SetParamsError = -10006,                                  //设置参数出错
    fitpolo701GetPackageError = -10007,                                 //升级固件的时候，传过来的固件数据出错
    fitpolo701UpdateError = -10008,                                     //升级失败
};

@interface fitpolo701Parser : NSObject

#pragma mark - blocks
+ (NSError *)getErrorWithCode:(fitpolo701CustomErrorCode)code message:(NSString *)message;
+ (void)operationCentralBlePowerOffBlock:(void (^)(NSError *error))block;
+ (void)operationConnectFailedBlock:(void (^)(NSError *error))block;
+ (void)operationDisconnectedErrorBlock:(void (^)(NSError *error))block;
+ (void)operationCharacteristicErrorBlock:(void (^)(NSError *error))block;
+ (void)operationRequestDataErrorBlock:(void (^)(NSError *error))block;
+ (void)operationParamsErrorBlock:(void (^)(NSError *error))block;
+ (void)operationSetParamsErrorBlock:(void (^)(NSError *error))block;
+ (void)operationGetPackageDataErrorBlock:(void (^)(NSError *error))block;
+ (void)operationUpdateErrorBlock:(void (^)(NSError *error))block;
+ (void)operationSetParamsResult:(id)returnData
                        sucBlock:(void (^)(id returnData))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock;
#pragma mark - parser

+ (NSInteger)getDecimalWithHex:(NSString *)content range:(NSRange)range;
+ (NSString *)getDecimalStringWithHex:(NSString *)content range:(NSRange)range;
+ (NSArray *)interceptionOfArray:(NSArray *)originalArray subRange:(NSRange)range;
+ (NSData *)getCrc16VerifyCode:(NSData *)data;
+ (NSString *)getAncsCommand:(fitpolo701AncsModel *)ancsModel;
+ (fitpolo701AncsModel *)getAncsOptions:(NSString *)content;
+ (NSString *)getAlarmClockType:(fitpolo701AlarmClockType)clockType;
+ (NSString *)getAlarlClockSetInfo:(fitpolo701StatusModel *)statusModel isOn:(BOOL)isOn;
+ (NSString *)getScreenDisplay:(fitpolo701ScreenDisplayModel *)displayModel;
+ (NSString *)hexStringFromData:(NSData *)sourceData;
+ (NSString *)getTimeStringWithDate:(NSDate *)date;
+ (NSString *)getCommandType:(fitpolo701TaskOperationID)operationID;
+ (NSData *)stringToData:(NSString *)dataString;
+ (BOOL)isMacAddress:(NSString *)macAddress;
+ (BOOL)isMacAddressLowFour:(NSString *)lowFour;
+ (BOOL)isUUIDString:(NSString *)uuid;
+ (BOOL)checkIdenty:(NSString *)identy;
+ (NSDictionary *)getHardwareParameters:(NSString *)content;
+ (NSDictionary *)getMemoryData:(NSString *)content;
+ (NSDictionary *)getStepData:(NSString *)content;
+ (NSDictionary *)getSleepIndexData:(NSString *)content;
+ (NSDictionary *)getSleepRecordData:(NSString *)content;
+ (NSArray *)getHeartRateData:(NSString *)content;
+ (NSDictionary *)getFirmwareVersion:(NSString *)content;
+ (NSArray *)getAlarmClockList:(NSString *)content;
+ (NSArray *)getSleepDataList:(NSArray *)indexList recordList:(NSArray *)recordList;
+ (NSDictionary *)getSedentaryRemindData:(NSString *)content;
+ (NSDictionary *)getConfigurationParameters:(NSString *)content;

@end

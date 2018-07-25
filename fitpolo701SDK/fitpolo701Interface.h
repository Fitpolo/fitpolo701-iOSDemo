//
//  fitpolo701Interface.h
//  testSDK
//
//  Created by aa on 2018/4/18.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "fitpolo701CentralManager.h"

typedef NS_ENUM(NSInteger, fitpolo701Unit) {
    fitpolo701MetricSystem,         //公制
    fitpolo701Imperial,             //英制
};

typedef NS_ENUM(NSInteger, fitpolo701Gender) {
    fitpolo701Male,             //男性
    fitpolo701Female,           //女性
};

typedef NS_ENUM(NSInteger, fitpolo701TimeFormat) {
    fitpolo70124Hour,         //24小时制
    fitpolo70112Hour,         //12小时制
};

typedef NS_ENUM(NSInteger, fitpolo701AlarmClockIndex) {
    fitpolo701AlarmClockIndexFirst,         //第一组闹钟
    fitpolo701AlarmClockIndexSecond,        //第二组闹钟
};

typedef NS_ENUM(NSInteger, fitpolo701HeartRateAcquisitionInterval) {
    fitpolo701HeartRateAcquisitionIntervalClose,    //关闭心率采集功能
    fitpolo701HeartRateAcquisitionInterval10Min,    //10分钟
    fitpolo701HeartRateAcquisitionInterval20Min,    //20分钟
    fitpolo701HeartRateAcquisitionInterval30Min,    //30分钟
};

typedef NS_ENUM(NSInteger, fitpolo701RequestDataWithTimeStamp) {
    fitpolo701RequestStepDataWithTimeStamp,         //时间戳请求计步数据
    fitpolo701RequestSleepIndexDataWithTimeStamp,   //时间戳请求睡眠index数据
    fitpolo701RequestSleepRecordDataWithTimeStamp,  //时间戳请求睡眠record数据
    fitpolo701RequestHeartRateDataWithTimeStamp,    //时间戳请求心率数据
};

@class fitpolo701AncsModel;
@class fitpolo701AlarmClockModel;
@class fitpolo701ScreenDisplayModel;
@interface fitpolo701Interface : NSObject

#pragma mark - 设置类指令
/**
 手环震动指令
 
 @param successBlock 成功Block
 @param failedBlock 失败Block
 */
+ (void)peripheralVibration:(fitpolo701CommunicationSuccessBlock)successBlock
                failedBlock:(fitpolo701CommunicationFailedBlock)failedBlock;
/**
 手环屏幕单位选择
 
 @param unit unit
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)peripheralUnitSwitch:(fitpolo701Unit)unit
                    sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                   failBlock:(fitpolo701CommunicationFailedBlock)failedBlock;
/**
 开启ancs提醒
 
 @param ancsModel ancsModel
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)peripheralCorrespondANCSNotice:(fitpolo701AncsModel *)ancsModel
                              sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                             failBlock:(fitpolo701CommunicationFailedBlock)failedBlock;
/**
 设置设备日期
 
 @param date 日期
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)peripheralSetDate:(NSDate *)date
                 sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                failBlock:(fitpolo701CommunicationFailedBlock)failedBlock;
/**
 设置个人信息给设备
 
 @param weight 用户体重，范围30~150，单位kg
 @param height 用户身高，范围100~200，单位cm
 @param age 用户年龄，5~99
 @param gender 用户性别
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)peripheralSetUserWeight:(NSInteger)weight
                         height:(NSInteger)height
                            age:(NSInteger)age
                         gender:(fitpolo701Gender)gender
                       sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                      failBlock:(fitpolo701CommunicationFailedBlock)failedBlock;
/**
 设置设备的时间进制
 
 @param timerFormat 24/12进制
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)peripheralSetTimeFormat:(fitpolo701TimeFormat)timerFormat
                       sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                      failBlock:(fitpolo701CommunicationFailedBlock)failedBlock;
/**
 设置设备的翻腕亮屏
 
 @param open YES:打开；NO:关闭
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)peripheralOpenPalmingBrightScreen:(BOOL)open
                                 sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                failBlock:(fitpolo701CommunicationFailedBlock)failedBlock;
/**
 设置设备闹钟
 
 @param list 闹钟列表，最多8个闹钟。如果list为nil或者个数为0，则认为关闭全部闹钟
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)peripheralSetAlarmClock:(NSArray <fitpolo701AlarmClockModel *>*)list
                       sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                      failBlock:(fitpolo701CommunicationFailedBlock)failedBlock;
/**
 设置设备是否记住上一次屏幕显示
 
 @param remind YES:记住，当手环亮屏的时候显示上一次屏幕熄灭时候的屏显。NO:当手环亮屏的时候显示时间屏显
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)peripheralRemindLastScreenDisplay:(BOOL)remind
                                 sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                failBlock:(fitpolo701CommunicationFailedBlock)failedBlock;
/**
 设置设备久坐提醒功能
 
 @param isOn YES:打开久坐提醒，NO:关闭久坐提醒,这种状态下，开始时间和结束时间就没有任何意义了
 @param startHour 久坐提醒开始时,0~23
 @param startMinutes 久坐提醒开始分,0~59
 @param endHour 久坐提醒结束时,0~23
 @param endMinutes 久坐提醒结束分,0~59
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)peripheralSetSedentaryRemind:(BOOL)isOn
                           startHour:(NSInteger)startHour
                        startMinutes:(NSInteger)startMinutes
                             endHour:(NSInteger)endHour
                          endMinutes:(NSInteger)endMinutes
                            sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                           failBlock:(fitpolo701CommunicationFailedBlock)failedBlock;
/**
 设置心率采集间隔
 
 @param intervalType 采集间隔
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)peripheralSetHeartRateAcquisitionInterval:(fitpolo701HeartRateAcquisitionInterval)intervalType
                                         sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                        failBlock:(fitpolo701CommunicationFailedBlock)failedBlock;
/**
 设置设备屏幕显示
 
 @param displayModel 屏幕显示model
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)peripheralSetScreenDisplay:(fitpolo701ScreenDisplayModel *)displayModel
                          sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                         failBlock:(fitpolo701CommunicationFailedBlock)failedBlock;
/**
 关闭手环ancs功能，目前只能断开设备与手机的连接，但是不能真正的关闭ancs，如果想要关闭ancs，只能在手机蓝牙列表里面忽略设备
 
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)peripheralCloseANCSWithSucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                              failBlock:(fitpolo701CommunicationFailedBlock)failedBlock;

@end

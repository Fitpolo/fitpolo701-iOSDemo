//
//  fitpolo701Models.h
//  fitpolo701SDKDemo
//
//  Created by aa on 2018/7/24.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface fitpolo701Models : NSObject
@end

#pragma mark - Alarm clock model
/**
 闹钟类型
 
 - alarmClockNormal: 普通闹钟
 */
typedef NS_ENUM(NSInteger, fitpolo701AlarmClockType) {
    fitpolo701AlarmClockNormal,           //普通
    fitpolo701AlarmClockMedicine,         //吃药
    fitpolo701AlarmClockDrink,            //喝水
    fitpolo701AlarmClockSleep,            //睡眠
    fitpolo701AlarmClockExcise,           //锻炼
    fitpolo701AlarmClockSport,            //运动
};

@interface fitpolo701StatusModel : NSObject

/**
 周一是否打开
 */
@property (nonatomic, assign)BOOL mondayIsOn;

/**
 周二是否打开
 */
@property (nonatomic, assign)BOOL tuesdayIsOn;

/**
 周三是否打开
 */
@property (nonatomic, assign)BOOL wednesdayIsOn;

/**
 周四是否打开
 */
@property (nonatomic, assign)BOOL thursdayIsOn;

/**
 周五是否打开
 */
@property (nonatomic, assign)BOOL fridayIsOn;

/**
 周六是否打开
 */
@property (nonatomic, assign)BOOL saturdayIsOn;

/**
 周日是否打开
 */
@property (nonatomic, assign)BOOL sundayIsOn;

@end

@interface fitpolo701AlarmClockModel : NSObject

/**
 闹钟是否打开
 */
@property (nonatomic, assign)BOOL isOn;

/**
 闹钟类型
 */
@property (nonatomic, assign)fitpolo701AlarmClockType clockType;

/**
 闹钟时
 */
@property (nonatomic, assign)NSInteger hour;

/**
 闹钟分
 */
@property (nonatomic, assign)NSInteger minutes;

/**
 闹钟状态
 */
@property (nonatomic, strong)fitpolo701StatusModel *statusModel;

@end


#pragma mark - ancs model
@interface fitpolo701AncsModel : NSObject

/**
 打开短信提醒
 */
@property (nonatomic, assign)BOOL openSMS;

/**
 打开电话提醒
 */
@property (nonatomic, assign)BOOL openPhone;

/**
 打开微信提醒
 */
@property (nonatomic, assign)BOOL openWeChat;

/**
 打开qq提醒
 */
@property (nonatomic, assign)BOOL openQQ;

/**
 打开whatsapp提醒
 */
@property (nonatomic, assign)BOOL openWhatsapp;

/**
 打开facebook提醒
 */
@property (nonatomic, assign)BOOL openFacebook;

/**
 打开twitter提醒
 */
@property (nonatomic, assign)BOOL openTwitter;

/**
 打开skype提醒
 */
@property (nonatomic, assign)BOOL openSkype;

/**
 打开snapchat提醒
 */
@property (nonatomic, assign)BOOL openSnapchat;

/**
 打开line提醒，注意，该选项是从32版本固件开始支持的
 */
@property (nonatomic, assign)BOOL openLine;

@end

#pragma mark - screen display model
@interface fitpolo701ScreenDisplayModel : NSObject

/**
 显示计步页面
 */
@property (nonatomic, assign)BOOL turnOnStepPage;

/**
 显示心率页面
 */
@property (nonatomic, assign)BOOL turnOnHeartRatePage;

/**
 显示运动距离页面
 */
@property (nonatomic, assign)BOOL turnOnSportsDistancePage;

/**
 显示卡路里页面
 */
@property (nonatomic, assign)BOOL turnOnCaloriesPage;

/**
 显示运动时间页面
 */
@property (nonatomic, assign)BOOL turnOnSportsTimePage;

@end

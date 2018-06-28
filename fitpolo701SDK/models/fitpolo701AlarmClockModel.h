//
//  fitpolo701AlarmClockModel.h
//  testSDK
//
//  Created by aa on 2018/3/16.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>

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

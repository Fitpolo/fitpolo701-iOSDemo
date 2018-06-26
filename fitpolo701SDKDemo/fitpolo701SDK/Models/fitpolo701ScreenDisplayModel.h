//
//  fitpolo701ScreenDisplayModel.h
//  testSDK
//
//  Created by aa on 2018/3/16.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>

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

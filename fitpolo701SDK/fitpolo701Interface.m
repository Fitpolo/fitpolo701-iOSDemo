//
//  fitpolo701Interface.m
//  testSDK
//
//  Created by aa on 2018/4/18.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo701Interface.h"
#import "fitpolo701Models.h"
#import "fitpolo701Defines.h"
#import "fitpolo701Parser.h"

@implementation fitpolo701Interface

#pragma mark - 设置类指令
/**
 手环震动指令
 
 @param successBlock 成功Block
 @param failedBlock 失败Block
 */
+ (void)peripheralVibration:(fitpolo701CommunicationSuccessBlock)successBlock
                failedBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    NSString *commandString = @"1702030a0a";
    [self addNewTask:fitpolo701VibrationOperation
         commandData:commandString
            sucBlock:successBlock
           failBlock:failedBlock];
}

/**
 手环屏幕单位选择
 
 @param unit unit
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)peripheralUnitSwitch:(fitpolo701Unit)unit
                    sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                   failBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    NSString *unitString = (unit == fitpolo701MetricSystem ? @"00" : @"01");
    NSString *commandString = [@"23" stringByAppendingString:unitString];
    [self addNewTask:fitpolo701SetUnitOperation
         commandData:commandString
            sucBlock:successBlock
           failBlock:failedBlock];
}

/**
 开启ancs提醒
 
 @param ancsModel ancsModel
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)peripheralCorrespondANCSNotice:(fitpolo701AncsModel *)ancsModel
                              sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                             failBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    if (!ancsModel) {
        [fitpolo701Parser operationParamsErrorBlock:failedBlock];
        return;
    }
    fitpolo701WS(weakSelf);
    [self peripheralOpenAncs:^(id returnData) {
        NSString *options = [fitpolo701Parser getAncsCommand:ancsModel];
        if (!fitpolo701ValidStr(options)) {
            [fitpolo701Parser operationParamsErrorBlock:failedBlock];
            return;
        }
        NSString *commandString = [NSString stringWithFormat:@"%@%@%@%@%@",@"16",@"10",@"00",@"00",options];
        [weakSelf addNewTask:fitpolo701SetANCSOptionsOperation commandData:commandString sucBlock:successBlock failBlock:failedBlock];
    } failedBlock:failedBlock];
}

/**
 设置设备日期
 
 @param date 日期
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)peripheralSetDate:(NSDate *)date
                 sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                failBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    if (!date) {
        [fitpolo701Parser operationParamsErrorBlock:failedBlock];
        return;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString *dateString = [formatter stringFromDate:date];
    NSArray *dateList = [dateString componentsSeparatedByString:@"-"];
    if (!fitpolo701ValidArray(dateList) || dateList.count != 6) {
        [fitpolo701Parser operationParamsErrorBlock:failedBlock];
        return;
    }
    NSInteger year = [dateList[0] integerValue];
    if (year < 2000 || year > 2099) {
        [fitpolo701Parser operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *yearString = [NSString stringWithFormat:@"%1lx",(long)(year - 2000)];
    if (yearString.length == 1) {
        yearString = [@"0" stringByAppendingString:yearString];
    }
    for (NSInteger i = 1; i < [dateList count]; i ++) {
        unsigned long tempValue = [dateList[i] integerValue];
        NSString *hexTempStr = [NSString stringWithFormat:@"%1lx",tempValue];
        if (hexTempStr.length == 1) {
            hexTempStr = [@"0" stringByAppendingString:hexTempStr];
        }
        yearString = [yearString stringByAppendingString:hexTempStr];
    }
    NSString *commandString = [@"11" stringByAppendingString:yearString];
    [self addNewTask:fitpolo701SetDateOperation
         commandData:commandString
            sucBlock:successBlock
           failBlock:failedBlock];
}

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
                      failBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    if (weight < 30
        || weight > 150
        || height < 100
        || height > 200
        || age < 5
        || age > 99) {
        //参数错误
        [fitpolo701Parser operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *ageString = [NSString stringWithFormat:@"%1lx",(unsigned long)age];
    if (ageString.length == 1) {
        ageString = [@"0" stringByAppendingString:ageString];
    }
    NSString *heightString = [NSString stringWithFormat:@"%1lx",(unsigned long)height];
    if (heightString.length == 1) {
        heightString = [@"0" stringByAppendingString:heightString];
    }
    NSString *weightString = [NSString stringWithFormat:@"%1lx",(unsigned long)weight];
    if (weightString.length == 1) {
        weightString = [@"0" stringByAppendingString:weightString];
    }
    //步距的计算方法:步长=身高*0.45 ,并且向下取整，程昂修改于2017年6月10号
    NSInteger stepAway = floor(height * 0.45);
    NSString *stepAwayString = [NSString stringWithFormat:@"%1lx",(unsigned long)stepAway];
    if (stepAwayString.length == 1) {
        stepAwayString = [@"0" stringByAppendingString:stepAwayString];
    }
    NSString *genderString = (gender == fitpolo701Male ? @"00" : @"01");
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                               @"12",
                               weightString,
                               heightString,
                               ageString,
                               genderString,
                               stepAwayString];
    [self addNewTask:fitpolo701SetUserInfoOperation
         commandData:commandString
            sucBlock:successBlock
           failBlock:failedBlock];
}

/**
 设置设备的时间进制
 
 @param timerFormat 24/12进制
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)peripheralSetTimeFormat:(fitpolo701TimeFormat)timerFormat
                       sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                      failBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    NSString *format = (timerFormat == fitpolo70124Hour ? @"00" : @"01");
    NSString *commandString = [@"24" stringByAppendingString:format];
    [self addNewTask:fitpolo701SetTimeFormatOperation
         commandData:commandString
            sucBlock:successBlock
           failBlock:failedBlock];
}

/**
 设置设备的翻腕亮屏
 
 @param open YES:打开；NO:关闭
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)peripheralOpenPalmingBrightScreen:(BOOL)open
                                 sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                failBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    NSString *state = (open ? @"00" : @"01");
    NSString *commandString = [@"25" stringByAppendingString:state];
    [self addNewTask:fitpolo701OpenPalmingBrightScreenOperation
         commandData:commandString
            sucBlock:successBlock
           failBlock:failedBlock];
}

/**
 设置设备闹钟
 
 @param list 闹钟列表，最多8个闹钟。如果list为nil或者个数为0，则认为关闭全部闹钟
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)peripheralSetAlarmClock:(NSArray <fitpolo701AlarmClockModel *>*)list
                       sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                      failBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    NSArray *firstList = nil;
    NSArray *secList = nil;
    if (!fitpolo701ValidArray(list)) {
        //关闭全部闹钟
    }else if (list.count <= 4){
        //一组闹钟
        firstList = list;
    }else if (list.count > 4 && list.count <= 8){
        //两组闹钟
        firstList = [fitpolo701Parser interceptionOfArray:list subRange:NSMakeRange(0, 4)];
        secList = [fitpolo701Parser interceptionOfArray:list subRange:NSMakeRange(4, list.count - 4)];
    }else{
        [fitpolo701Parser operationParamsErrorBlock:failedBlock];
        return;
    }
    fitpolo701WS(weakSelf);
    [self peripheralSetAlarmClock:fitpolo701AlarmClockIndexFirst alarmClockList:firstList sucBlock:^(id returnData) {
        [weakSelf peripheralSetAlarmClock:fitpolo701AlarmClockIndexSecond alarmClockList:secList sucBlock:successBlock failBlock:failedBlock];
    } failBlock:failedBlock];
}

/**
 设置设备是否记住上一次屏幕显示
 
 @param remind YES:记住，当手环亮屏的时候显示上一次屏幕熄灭时候的屏显。NO:当手环亮屏的时候显示时间屏显
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)peripheralRemindLastScreenDisplay:(BOOL)remind
                                 sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                failBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    NSString *status = (remind ? @"01" : @"00");
    NSString *commandString = [@"27" stringByAppendingString:status];
    [self addNewTask:fitpolo701RemindLastScreenDisplayOperation
         commandData:commandString
            sucBlock:successBlock
           failBlock:failedBlock];
}

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
                           failBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    if (startHour < 0 || startHour > 23) {
        [fitpolo701Parser operationParamsErrorBlock:failedBlock];
        return;
    }
    if (startMinutes < 0 || startMinutes > 59) {
        [fitpolo701Parser operationParamsErrorBlock:failedBlock];
        return;
    }
    if (endHour < 0 || endHour > 23) {
        [fitpolo701Parser operationParamsErrorBlock:failedBlock];
        return;
    }
    if (endMinutes < 0 || endMinutes > 59) {
        [fitpolo701Parser operationParamsErrorBlock:failedBlock];
        return;
    }
    NSMutableArray *tempDataList = [NSMutableArray array];
    for (NSInteger i = 0; i < 16; i ++) {
        [tempDataList addObject:@"00"];
    }
    if (isOn) {
        [tempDataList replaceObjectAtIndex:1 withObject:@"ff"];
    }
    //久坐提醒开始的时
    NSString *startHourHex = [NSString stringWithFormat:@"%1lx",(unsigned long)startHour];
    if (startHourHex.length == 1) {
        startHourHex = [@"0" stringByAppendingString:startHourHex];
    }
    [tempDataList replaceObjectAtIndex:2 withObject:startHourHex];
    //久坐提醒开始的分
    NSString *startMinHex = [NSString stringWithFormat:@"%1lx",(unsigned long)startMinutes];
    if (startMinHex.length == 1) {
        startMinHex = [@"0" stringByAppendingString:startMinHex];
    }
    [tempDataList replaceObjectAtIndex:3 withObject:startMinHex];
    //久坐提醒结束的时
    NSString *endHourHex = [NSString stringWithFormat:@"%1lx",(unsigned long)endHour];
    if (endHourHex.length == 1) {
        endHourHex = [@"0" stringByAppendingString:endHourHex];
    }
    [tempDataList replaceObjectAtIndex:4 withObject:endHourHex];
    //久坐提醒结束的分
    NSString *endMinHex = [NSString stringWithFormat:@"%1lx",(unsigned long)endMinutes];
    if (endMinHex.length == 1) {
        endMinHex = [@"0" stringByAppendingString:endMinHex];
    }
    [tempDataList replaceObjectAtIndex:5 withObject:endMinHex];
    NSString *commandString = @"2a";
    for (NSString *string in tempDataList) {
        commandString = [commandString stringByAppendingString:string];
    }
    [self addNewTask:fitpolo701SetSedentaryRemindOperation
         commandData:commandString
            sucBlock:successBlock
           failBlock:failedBlock];
}

/**
 设置心率采集间隔
 
 @param intervalType 采集间隔
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)peripheralSetHeartRateAcquisitionInterval:(fitpolo701HeartRateAcquisitionInterval)intervalType
                                         sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                        failBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    NSString *type = @"00";
    if (intervalType == fitpolo701HeartRateAcquisitionInterval10Min) {
        type = @"01";
    }else if (intervalType == fitpolo701HeartRateAcquisitionInterval20Min){
        type = @"02";
    }else if (intervalType == fitpolo701HeartRateAcquisitionInterval30Min){
        type = @"03";
    }
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@%@",@"16",@"17",type,@"00"];
    [self addNewTask:fitpolo701SetHeartRateAcquisitionIntervalOperation
         commandData:commandString
            sucBlock:successBlock
           failBlock:failedBlock];
}

/**
 设置设备屏幕显示
 
 @param displayModel 屏幕显示model
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)peripheralSetScreenDisplay:(fitpolo701ScreenDisplayModel *)displayModel
                          sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                         failBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    if (!displayModel) {
        [fitpolo701Parser operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *screenDisplay = [fitpolo701Parser getScreenDisplay:displayModel];
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@%@",@"16",@"19",@"000000",screenDisplay];
    [self addNewTask:fitpolo701SetScreenDisplayOperation
         commandData:commandString
            sucBlock:successBlock
           failBlock:failedBlock];
}

/**
 关闭手环ancs功能，目前只能断开设备与手机的连接，但是不能真正的关闭ancs，如果想要关闭ancs，只能在手机蓝牙列表里面忽略设备
 
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)peripheralCloseANCSWithSucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                              failBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    NSString *commandString = @"1616";
    [self addNewTask:fitpolo701CloseANCSOperation
         commandData:commandString
            sucBlock:successBlock
           failBlock:failedBlock];
}

#pragma mark - Private method
+ (void)addNewTask:(fitpolo701TaskOperationID)taskID
       commandData:(NSString *)commandData
          sucBlock:(fitpolo701CommunicationSuccessBlock)sucBlock
         failBlock:(fitpolo701CommunicationFailedBlock)failBlock{
    [[fitpolo701CentralManager sharedInstance] addTaskWithTaskID:taskID
                                                        resetNum:NO
                                                     commandData:commandData
                                                    successBlock:sucBlock
                                                    failureBlock:failBlock];
}

/**
 手环开启ancs指令
 
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)peripheralOpenAncs:(fitpolo701CommunicationSuccessBlock)successBlock
               failedBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    NSString *commandString = @"160f";
    [self addNewTask:fitpolo701OpenANCSOperation
         commandData:commandString
            sucBlock:successBlock
           failBlock:failedBlock];
}

/**
 设置闹钟
 
 @param index 闹钟组别
 @param list 闹钟数据,最多4个,如果个数少于一个或者直接nil的情况下，关闭该组别所有闹钟
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)peripheralSetAlarmClock:(fitpolo701AlarmClockIndex)index
                 alarmClockList:(NSArray <fitpolo701AlarmClockModel *>*)list
                       sucBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                      failBlock:(fitpolo701CommunicationFailedBlock)failedBlock{
    if (list.count > 4) {
        [fitpolo701Parser operationParamsErrorBlock:failedBlock];
        return;
    }
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSInteger i = 0; i < 16; i ++) {
        [tempArray addObject:@"00"];
    }
    for (NSInteger i = 0; i < list.count; i ++) {
        fitpolo701AlarmClockModel *clockModel = list[i];
        if (clockModel.hour < 0 || clockModel.hour > 23) {
            [fitpolo701Parser operationParamsErrorBlock:failedBlock];
            return;
        }
        if (clockModel.minutes < 0 || clockModel.minutes > 59) {
            [fitpolo701Parser operationParamsErrorBlock:failedBlock];
            return;
        }
        NSString *clockType = [fitpolo701Parser getAlarmClockType:clockModel.clockType];
        [tempArray replaceObjectAtIndex:i * 4 withObject:clockType];
        NSString *clockSetting = [fitpolo701Parser getAlarlClockSetInfo:clockModel.statusModel isOn:clockModel.isOn];
        [tempArray replaceObjectAtIndex:(i * 4 + 1) withObject:clockSetting];
        NSString *hexHour = [NSString stringWithFormat:@"%1lx",(unsigned long)clockModel.hour];
        if (hexHour.length == 1) {
            hexHour = [@"0" stringByAppendingString:hexHour];
        }
        [tempArray replaceObjectAtIndex:(i * 4 + 2) withObject:hexHour];
        NSString *hexMin = [NSString stringWithFormat:@"%1lx",(unsigned long)clockModel.minutes];
        if (hexMin.length == 1) {
            hexMin = [@"0" stringByAppendingString:hexMin];
        }
        [tempArray replaceObjectAtIndex:(i * 4 + 3) withObject:hexMin];
    }
    NSString *indexString = (index == fitpolo701AlarmClockIndexFirst ? @"00" : @"01");
    NSString *commandString = [@"26" stringByAppendingString:indexString];
    for (NSString *string in tempArray) {
        commandString = [commandString stringByAppendingString:string];
    }
    [self addNewTask:fitpolo701SetAlarmClockOperation
         commandData:commandString
            sucBlock:successBlock
           failBlock:failedBlock];
}

@end

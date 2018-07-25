//
//  fitpolo701DataParser.m
//  testSDK
//
//  Created by aa on 2018/3/15.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo701DataParser.h"
#import "fitpolo701Defines.h"
#import "fitpolo701LogManager.h"
#import "fitpolo701Parser.h"
#import "fitpolo701Models.h"

NSString *const fitpolo701CommunicationDataNum = @"fitpolo701CommunicationDataNum";

@implementation fitpolo701DataParser

#pragma mark - data process method
+ (NSDictionary *)parse96HeaderData:(NSString *)content{
    if (!fitpolo701ValidStr(content) || (content.length != 2 && content.length != 8)) {
        return nil;
    }
    NSString *origData = [NSString stringWithFormat:@"手环返回数据:96%@",content];
    [fitpolo701LogManager writeCommandToLocalFile:@[origData] withSourceInfo:fitpolo701DataSourceDevice];
    NSString *function = [content substringWithRange:NSMakeRange(0, 2)];
    fitpolo701TaskOperationID operationID = fitpolo701DefaultTaskOperationID;
    NSDictionary *result = @{};
    if ([function isEqualToString:@"17"] && content.length == 2) {
        //震动
        operationID = fitpolo701VibrationOperation;
    }else if ([function isEqualToString:@"23"] && content.length == 2){
        //单位进制切换
        operationID = fitpolo701SetUnitOperation;
    }else if ([function isEqualToString:@"0f"] && content.length == 2){
        //开启ancs
        operationID = fitpolo701OpenANCSOperation;
    }else if ([function isEqualToString:@"10"] && content.length == 2){
        //设置ancs提醒选项
        operationID = fitpolo701SetANCSOptionsOperation;
    }else if ([function isEqualToString:@"11"] && content.length == 2){
        //设置日期
        operationID = fitpolo701SetDateOperation;
    }else if ([function isEqualToString:@"12"] && content.length == 2){
        //设置个人信息
        operationID = fitpolo701SetUserInfoOperation;
    }else if ([function isEqualToString:@"24"] && content.length == 2){
        //设置时间进制
        operationID = fitpolo701SetTimeFormatOperation;
    }else if ([function isEqualToString:@"25"] && content.length == 2){
        //设置翻腕亮屏
        operationID = fitpolo701OpenPalmingBrightScreenOperation;
    }else if ([function isEqualToString:@"26"] && content.length == 2){
        //设置闹钟
        operationID = fitpolo701SetAlarmClockOperation;
    }else if ([function isEqualToString:@"27"] && content.length == 2){
        //设置记住上一次屏幕显示
        operationID = fitpolo701RemindLastScreenDisplayOperation;
    }else if ([function isEqualToString:@"28"] && content.length == 2){
        //开启升级
        operationID = fitpolo701StartUpdateOperation;
    }else if ([function isEqualToString:@"2a"] && content.length == 2){
        //设置久坐提醒
        operationID = fitpolo701SetSedentaryRemindOperation;
    }else if ([function isEqualToString:@"09"] && content.length == 8){
        //内部版本号
        operationID = fitpolo701GetInternalVersionOperation;
        result = @{
                   @"internalVersion":[content substringWithRange:NSMakeRange(2, 6)],
                   };
    }
    return [self dataParserGetDataSuccess:result operationID:operationID];
}

+ (NSDictionary *)parseA5HeaderData:(NSString *)content{
    if (!fitpolo701ValidStr(content) || (content.length != 2 && content.length != 38 && content.length != 10)) {
        return nil;
    }
    NSString *origData = [NSString stringWithFormat:@"手环返回数据:a5%@",content];
    [fitpolo701LogManager writeCommandToLocalFile:@[origData] withSourceInfo:fitpolo701DataSourceDevice];
    NSString *function = [content substringWithRange:NSMakeRange(0, 2)];
    fitpolo701TaskOperationID operationID = fitpolo701DefaultTaskOperationID;
    NSDictionary *result = @{};
    if ([function isEqualToString:@"17"] && content.length == 2) {
        //设置心率采集间隔
        operationID = fitpolo701SetHeartRateAcquisitionIntervalOperation;
    }else if ([function isEqualToString:@"19"] && content.length == 2){
        //设置屏幕显示
        operationID = fitpolo701SetScreenDisplayOperation;
    }else if ([function isEqualToString:@"16"] && content.length == 2){
        //关闭ancs
        operationID = fitpolo701CloseANCSOperation;
    }else if ([function isEqualToString:@"22"] && content.length == 38){
        //硬件参数
        operationID = fitpolo701GetHardwareParametersOperation;
        result = @{
                   @"hardwareParameters":[fitpolo701Parser getHardwareParameters:content],
                   };
    }else if ([function isEqualToString:@"11"] && content.length == 10){
        //ancs选项
        operationID = fitpolo701GetANCSOptionsOperation;
        result = @{
                   @"ancsOptionsModel":[fitpolo701Parser getAncsOptions:content],
                   };
    }
    return [self dataParserGetDataSuccess:result operationID:operationID];
}

+ (NSDictionary *)parse91HeaderData:(NSString *)content{
    if (!fitpolo701ValidStr(content) || content.length != 6) {
        return nil;
    }
    return [self dataParserGetDataSuccess:[fitpolo701Parser getMemoryData:content] operationID:fitpolo701GetMemoryDataOperation];
}

+ (NSDictionary *)parse92HeaderData:(NSString *)content{
    if (!fitpolo701ValidStr(content) || content.length != 28) {
        return nil;
    }
    return [self dataParserGetDataSuccess:[fitpolo701Parser getStepData:content] operationID:fitpolo701GetStepDataOperation];
}

+ (NSDictionary *)parse93HeaderData:(NSString *)content{
    if (!fitpolo701ValidStr(content) || content.length != 34) {
        return nil;
    }
    return [self dataParserGetDataSuccess:[fitpolo701Parser getSleepIndexData:content] operationID:fitpolo701GetSleepIndexOperation];
}

+ (NSDictionary *)parse94HeaderData:(NSString *)content{
    if (!fitpolo701ValidStr(content) || content.length < 8) {
        return nil;
    }
    return [self dataParserGetDataSuccess:[fitpolo701Parser getSleepRecordData:content] operationID:fitpolo701GetSleepRecordOperation];
}

+ (NSDictionary *)parseA8HeaderData:(NSString *)content{
    if (!fitpolo701ValidStr(content) || content.length != 38) {
        return nil;
    }
    NSDictionary *dic = @{
                          @"heartList":[fitpolo701Parser getHeartRateData:[content substringWithRange:NSMakeRange(2, 36)]]
                          };
    return [self dataParserGetDataSuccess:dic operationID:fitpolo701GetHeartDataOperation];
}

+ (NSDictionary *)parse90HeaderData:(NSString *)content{
    if (!fitpolo701ValidStr(content) || content.length != 6) {
        return nil;
    }
    return [self dataParserGetDataSuccess:[fitpolo701Parser getFirmwareVersion:content] operationID:fitpolo701GetFirmwareVersionOperation];
}

+ (NSDictionary *)parseAAHeaderData:(NSString *)content{
    if (!fitpolo701ValidStr(content) || content.length != 4) {
        return nil;
    }
    NSString *origData = [NSString stringWithFormat:@"手环最新数据数据:aa%@",content];
    [fitpolo701LogManager writeCommandToLocalFile:@[origData] withSourceInfo:fitpolo701DataSourceDevice];
    NSString *function = [content substringWithRange:NSMakeRange(0, 2)];
    NSDictionary *dic = @{
                         fitpolo701CommunicationDataNum:[fitpolo701Parser getDecimalStringWithHex:content range:NSMakeRange(2, 2)]
                         };
    fitpolo701TaskOperationID operationID = fitpolo701DefaultTaskOperationID;
    NSString *msgInfo = @"";
    if ([function isEqualToString:@"92"]) {
        operationID = fitpolo701GetStepDataOperation;
        msgInfo = @"最新计步数据";
    }else if ([function isEqualToString:@"93"]){
        operationID = fitpolo701GetSleepIndexOperation;
        msgInfo = @"最新睡眠index数据";
    }else if ([function isEqualToString:@"94"]){
        operationID = fitpolo701GetSleepRecordOperation;
        msgInfo = @"最新睡眠record数据";
    }else if ([function isEqualToString:@"a8"]){
        operationID = fitpolo701GetHeartDataOperation;
        msgInfo = @"最新心率数据";
    }
    NSString *tempString = [NSString stringWithFormat:@"%@%@条",msgInfo,[fitpolo701Parser getDecimalStringWithHex:content range:NSMakeRange(2, 2)]];
    [fitpolo701LogManager writeCommandToLocalFile:@[tempString] withSourceInfo:fitpolo701DataSourceDevice];
    return [self dataParserGetDataSuccess:dic operationID:operationID];
}

+ (NSDictionary *)parseB1HeaderData:(NSString *)content{
    if (!fitpolo701ValidStr(content) || content.length < 4) {
        return nil;
    }
    NSString *origData = [NSString stringWithFormat:@"手环返回数据:b1%@",content];
    [fitpolo701LogManager writeCommandToLocalFile:@[origData] withSourceInfo:fitpolo701DataSourceDevice];
    NSString *funtion = [content substringWithRange:NSMakeRange(0, 2)];
    fitpolo701TaskOperationID operationID = fitpolo701DefaultTaskOperationID;
    NSDictionary *dic = nil;
    if ([funtion isEqualToString:@"01"] && content.length == 36) {
        //闹钟数据
        operationID = fitpolo701GetAlarmClockDataOperation;
        dic = @{
                @"clockList":[fitpolo701Parser getAlarmClockList:[content substringWithRange:NSMakeRange(4, 32)]]
                };
    }else if ([funtion isEqualToString:@"02"] && content.length == 14){
        //久坐提醒
        operationID = fitpolo701GetSedentaryRemindOperation;
        dic = @{
                @"sedentaryRemind":[fitpolo701Parser getSedentaryRemindData:[content substringWithRange:NSMakeRange(4, 10)]]
                };
    }else if ([funtion isEqualToString:@"04"] && content.length == 16){
        //配置参数
        operationID = fitpolo701GetConfigurationParametersOperation;
        dic = @{
                @"configurationParameters":[fitpolo701Parser getConfigurationParameters:[content substringWithRange:NSMakeRange(4, 12)]]
                };
    }
    return [self dataParserGetDataSuccess:dic operationID:operationID];
}

#pragma mark - Private method
+ (NSDictionary *)dataParserGetDataSuccess:(NSDictionary *)returnData operationID:(fitpolo701TaskOperationID)operationID{
    if (!returnData) {
        return nil;
    }
    return @{@"returnData":returnData,@"operationID":@(operationID)};
}

#pragma mark - Public method

+ (NSDictionary *)parseReadData:(NSString *)readData{
    if (!fitpolo701ValidStr(readData) || readData.length < 4) {
        return nil;
    }
    NSString *header = [readData substringWithRange:NSMakeRange(0, 2)];
    if ([header isEqualToString:@"96"]) {
        return [self parse96HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"a5"]){
        return [self parseA5HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"91"]){
        return [self parse91HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"92"]){
        return [self parse92HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"93"]){
        return [self parse93HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"94"]){
        return [self parse94HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"a8"]){
        return [self parseA8HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"90"]){
        return [self parse90HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"aa"]){
        return [self parseAAHeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"b1"]){
        return [self parseB1HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }
    return nil;
}

@end

//
//  fitpolo701DataParser.m
//  testSDK
//
//  Created by aa on 2018/3/15.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo701DataParser.h"
#import "fitpolo701RegularsDefine.h"
#import "fitpolo701LogManager.h"
#import "fitpolo701Parser.h"
#import "fitpolo701ConstDefines.h"
#import "fitpolo701AncsModel.h"

NSString *const fitpolo701CommunicationDataNum = @"fitpolo701CommunicationDataNum";

@implementation fitpolo701ParseResultModel

@end

@implementation fitpolo701DataParser

#pragma mark - life circle

- (void)dealloc{
    NSLog(@"数据解析中心销毁");
}

#pragma mark - data process method
- (void)parse96HeaderData:(NSString *)content{
    if (!fitpolo701ValidStr(content) || (content.length != 2 && content.length != 8)) {
        return;
    }
    NSString *origData = [NSString stringWithFormat:@"手环返回数据:96%@",content];
    [fitpolo701LogManager writeCommandToLocalFile:@[origData] withSourceInfo:fitpolo701DataSourceDevice];
    NSString *function = [content substringWithRange:NSMakeRange(0, 2)];
    fitpolo701ParseResultModel *model = [[fitpolo701ParseResultModel alloc] init];
    model.returnData = @{};
    if ([function isEqualToString:@"17"] && content.length == 2) {
        //震动
        model.operationID = fitpolo701VibrationOperation;
    }else if ([function isEqualToString:@"23"] && content.length == 2){
        //单位进制切换
        model.operationID = fitpolo701SetUnitOperation;
    }else if ([function isEqualToString:@"0f"] && content.length == 2){
        //开启ancs
        model.operationID = fitpolo701OpenANCSOperation;
    }else if ([function isEqualToString:@"10"] && content.length == 2){
        //设置ancs提醒选项
        model.operationID = fitpolo701SetANCSOptionsOperation;
    }else if ([function isEqualToString:@"11"] && content.length == 2){
        //设置日期
        model.operationID = fitpolo701SetDateOperation;
    }else if ([function isEqualToString:@"12"] && content.length == 2){
        //设置个人信息
        model.operationID = fitpolo701SetUserInfoOperation;
    }else if ([function isEqualToString:@"24"] && content.length == 2){
        //设置时间进制
        model.operationID = fitpolo701SetTimeFormatOperation;
    }else if ([function isEqualToString:@"25"] && content.length == 2){
        //设置翻腕亮屏
        model.operationID = fitpolo701OpenPalmingBrightScreenOperation;
    }else if ([function isEqualToString:@"26"] && content.length == 2){
        //设置闹钟
        model.operationID = fitpolo701SetAlarmClockOperation;
    }else if ([function isEqualToString:@"27"] && content.length == 2){
        //设置记住上一次屏幕显示
        model.operationID = fitpolo701RemindLastScreenDisplayOperation;
    }else if ([function isEqualToString:@"28"] && content.length == 2){
        //开启升级
        model.operationID = fitpolo701StartUpdateOperation;
    }else if ([function isEqualToString:@"2a"] && content.length == 2){
        //设置久坐提醒
        model.operationID = fitpolo701SetSedentaryRemindOperation;
    }else if ([function isEqualToString:@"09"] && content.length == 8){
        //内部版本号
        model.operationID = fitpolo701GetInternalVersionOperation;
        model.returnData = @{
                             @"internalVersion":[content substringWithRange:NSMakeRange(2, 6)],
                             };
    }
    [self addDataToList:model];
}

- (void)parseA5HeaderData:(NSString *)content{
    if (!fitpolo701ValidStr(content) || (content.length != 2 && content.length != 38 && content.length != 10)) {
        return;
    }
    NSString *origData = [NSString stringWithFormat:@"手环返回数据:a5%@",content];
    [fitpolo701LogManager writeCommandToLocalFile:@[origData] withSourceInfo:fitpolo701DataSourceDevice];
    NSString *function = [content substringWithRange:NSMakeRange(0, 2)];
    fitpolo701ParseResultModel *model = [[fitpolo701ParseResultModel alloc] init];
    model.returnData = @{};
    if ([function isEqualToString:@"17"] && content.length == 2) {
        //设置心率采集间隔
        model.operationID = fitpolo701SetHeartRateAcquisitionIntervalOperation;
    }else if ([function isEqualToString:@"19"] && content.length == 2){
        //设置屏幕显示
        model.operationID = fitpolo701SetScreenDisplayOperation;
    }else if ([function isEqualToString:@"16"] && content.length == 2){
        //关闭ancs
        model.operationID = fitpolo701CloseANCSOperation;
    }else if ([function isEqualToString:@"22"] && content.length == 38){
        //硬件参数
        model.operationID = fitpolo701GetHardwareParametersOperation;
        model.returnData = @{
                                @"hardwareParameters":[fitpolo701Parser getHardwareParameters:content],
                             };
    }else if ([function isEqualToString:@"11"] && content.length == 10){
        //ancs选项
        model.operationID = fitpolo701GetANCSOptionsOperation;
        model.returnData = @{
                                @"ancsOptionsModel":[fitpolo701Parser getAncsOptions:content],
                             };
    }
    [self addDataToList:model];
}

- (void)parse91HeaderData:(NSString *)content{
    if (!fitpolo701ValidStr(content) || content.length != 6) {
        return;
    }
    fitpolo701ParseResultModel *model = [[fitpolo701ParseResultModel alloc] init];
    model.operationID = fitpolo701GetMemoryDataOperation;
    model.returnData = [fitpolo701Parser getMemoryData:content];
    [self addDataToList:model];
}

- (void)parse92HeaderData:(NSString *)content{
    if (!fitpolo701ValidStr(content) || content.length != 28) {
        return;
    }
    fitpolo701ParseResultModel *model = [[fitpolo701ParseResultModel alloc] init];
    model.operationID = fitpolo701GetStepDataOperation;
    model.returnData = [fitpolo701Parser getStepData:content];
    [self addDataToList:model];
    
}

- (void)parse93HeaderData:(NSString *)content{
    if (!fitpolo701ValidStr(content) || content.length != 34) {
        return;
    }
    fitpolo701ParseResultModel *model = [[fitpolo701ParseResultModel alloc] init];
    model.operationID = fitpolo701GetSleepIndexOperation;
    model.returnData = [fitpolo701Parser getSleepIndexData:content];
    [self addDataToList:model];
}

- (void)parse94HeaderData:(NSString *)content{
    if (!fitpolo701ValidStr(content) || content.length < 8) {
        return;
    }
    
    fitpolo701ParseResultModel *model = [[fitpolo701ParseResultModel alloc] init];
    model.operationID = fitpolo701GetSleepRecordOperation;
    model.returnData = [fitpolo701Parser getSleepRecordData:content];
    [self addDataToList:model];
    
}

- (void)parseA8HeaderData:(NSString *)content{
    if (!fitpolo701ValidStr(content) || content.length != 38) {
        return;
    }
    fitpolo701ParseResultModel *model = [[fitpolo701ParseResultModel alloc] init];
    model.operationID = fitpolo701GetHeartDataOperation;
    model.returnData = @{
                         @"heartList":[fitpolo701Parser getHeartRateData:[content substringWithRange:NSMakeRange(2, 36)]]
                         };
    [self addDataToList:model];
}

- (void)parse90HeaderData:(NSString *)content{
    if (!fitpolo701ValidStr(content) || content.length != 6) {
        return;
    }
    
    fitpolo701ParseResultModel *model = [[fitpolo701ParseResultModel alloc] init];
    model.operationID = fitpolo701GetFirmwareVersionOperation;
    model.returnData = [fitpolo701Parser getFirmwareVersion:content];
    [self addDataToList:model];
    
}

- (void)parseAAHeaderData:(NSString *)content{
    if (!fitpolo701ValidStr(content) || content.length != 4) {
        return;
    }
    NSString *origData = [NSString stringWithFormat:@"手环最新数据数据:aa%@",content];
    [fitpolo701LogManager writeCommandToLocalFile:@[origData] withSourceInfo:fitpolo701DataSourceDevice];
    NSString *function = [content substringWithRange:NSMakeRange(0, 2)];
    fitpolo701ParseResultModel *model = [[fitpolo701ParseResultModel alloc] init];
    model.returnData = @{
                         fitpolo701CommunicationDataNum:[fitpolo701Parser getDecimalStringWithHex:content range:NSMakeRange(2, 2)]
                         };
    NSString *msgInfo = @"";
    if ([function isEqualToString:@"92"]) {
        model.operationID = fitpolo701GetStepDataOperation;
        msgInfo = @"最新计步数据";
    }else if ([function isEqualToString:@"93"]){
        model.operationID = fitpolo701GetSleepIndexOperation;
        msgInfo = @"最新睡眠index数据";
    }else if ([function isEqualToString:@"94"]){
        model.operationID = fitpolo701GetSleepRecordOperation;
        msgInfo = @"最新睡眠record数据";
    }else if ([function isEqualToString:@"a8"]){
        model.operationID = fitpolo701GetHeartDataOperation;
        msgInfo = @"最新心率数据";
    }
    
    [self addDataToList:model];
    NSString *tempString = [NSString stringWithFormat:@"%@%@条",msgInfo,[fitpolo701Parser getDecimalStringWithHex:content range:NSMakeRange(2, 2)]];
    [fitpolo701LogManager writeCommandToLocalFile:@[tempString] withSourceInfo:fitpolo701DataSourceDevice];
}

- (void)parseA7HeaderData:(NSString *)content{
    if (!fitpolo701ValidStr(content) || content.length != 2) {
        return;
    }
    NSString *origData = [NSString stringWithFormat:@"手环升级结果数据:a7%@",content];
    [fitpolo701LogManager writeCommandToLocalFile:@[origData] withSourceInfo:fitpolo701DataSourceDevice];
    //抛出升级结果通知，@"00"成功@"01"超时@"02"校验码错误@"03"文件错误
    [[NSNotificationCenter defaultCenter] postNotificationName:fitpolo701PeripheralUpdateResultNotification
                                                        object:nil
                                                      userInfo:@{@"updateResult" : content}];
}

- (void)parseB1HeaderData:(NSString *)content{
    if (!fitpolo701ValidStr(content) || content.length < 4) {
        return;
    }
    NSString *origData = [NSString stringWithFormat:@"手环返回数据:b1%@",content];
    [fitpolo701LogManager writeCommandToLocalFile:@[origData] withSourceInfo:fitpolo701DataSourceDevice];
    NSString *funtion = [content substringWithRange:NSMakeRange(0, 2)];
    if ([funtion isEqualToString:@"01"] && content.length == 36) {
        //闹钟数据
        fitpolo701ParseResultModel *model = [[fitpolo701ParseResultModel alloc] init];
        model.operationID = fitpolo701GetAlarmClockDataOperation;
        model.returnData = @{
                             @"clockList":[fitpolo701Parser getAlarmClockList:[content substringWithRange:NSMakeRange(4, 32)]]
                             };
        [self addDataToList:model];
    }else if ([funtion isEqualToString:@"02"] && content.length == 14){
        //久坐提醒
        fitpolo701ParseResultModel *model = [[fitpolo701ParseResultModel alloc] init];
        model.operationID = fitpolo701GetSedentaryRemindOperation;
        model.returnData = @{
                             @"sedentaryRemind":[fitpolo701Parser getSedentaryRemindData:[content substringWithRange:NSMakeRange(4, 10)]]
                             };
        [self addDataToList:model];
    }else if ([funtion isEqualToString:@"04"] && content.length == 16){
        //配置参数
        fitpolo701ParseResultModel *model = [[fitpolo701ParseResultModel alloc] init];
        model.operationID = fitpolo701GetConfigurationParametersOperation;
        model.returnData = @{
                             @"configurationParameters":[fitpolo701Parser getConfigurationParameters:[content substringWithRange:NSMakeRange(4, 12)]]
                             };
        [self addDataToList:model];
    }
}

#pragma mark - Private method
- (void)addDataToList:(fitpolo701ParseResultModel *)dataModel{
    if (!dataModel) {
        return;
    }
    [[self mutableArrayValueForKey:@"dataList"] removeAllObjects];
    [[self mutableArrayValueForKey:@"dataList"] addObject:dataModel];
}

#pragma mark - Public method

- (void)parseReadData:(NSString *)readData{
    if (!fitpolo701ValidStr(readData) || readData.length < 4) {
        return;
    }
    NSLog(@"接收到的数据:%@",readData);
    NSString *header = [readData substringWithRange:NSMakeRange(0, 2)];
    if ([header isEqualToString:@"96"]) {
        [self parse96HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"a5"]){
        [self parseA5HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"91"]){
        [self parse91HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"92"]){
        [self parse92HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"93"]){
        [self parse93HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"94"]){
        [self parse94HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"a8"]){
        [self parseA8HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"90"]){
        [self parse90HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"a7"]){
        [self parseA7HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"aa"]){
        [self parseAAHeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"b1"]){
        [self parseB1HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }
}

#pragma mark - setter & getter
- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

@end

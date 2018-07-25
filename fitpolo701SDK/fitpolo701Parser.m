//
//  fitpolo701Parser.m
//  testSDK
//
//  Created by aa on 2018/3/13.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo701Parser.h"
#import "fitpolo701Defines.h"
#import "fitpolo701LogManager.h"

static NSString *const uuidPatternString = @"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$";
static NSString * const fitpolo701CustomErrorDomain = @"com.moko.fitpoloBluetoothSDK";

@implementation fitpolo701Parser

#pragma mark - blocks
+ (NSError *)getErrorWithCode:(fitpolo701CustomErrorCode)code message:(NSString *)message{
    NSError *error = [[NSError alloc] initWithDomain:fitpolo701CustomErrorDomain
                                                code:code
                                            userInfo:@{@"errorInfo":message}];
    return error;
}

+ (void)operationCentralBlePowerOffBlock:(void (^)(NSError *error))block{
    fitpolo701_main_safe(^{
        if (block) {
            NSError *error = [self getErrorWithCode:fitpolo701BlueDisable message:@"mobile phone bluetooth is currently unavailable"];
            block(error);
        }
    });
}

+ (void)operationConnectFailedBlock:(void (^)(NSError *error))block{
    fitpolo701_main_safe(^{
        if (block) {
            NSError *error = [self getErrorWithCode:fitpolo701ConnectedFailed message:@"connect failed"];
            block(error);
        }
    });
}

+ (void)operationDisconnectedErrorBlock:(void (^)(NSError *error))block{
    fitpolo701_main_safe(^{
        if (block) {
            NSError *error = [self getErrorWithCode:fitpolo701PeripheralDisconnected message:@"the current connection device is in disconnect"];
            block(error);
        }
    });
}

+ (void)operationCharacteristicErrorBlock:(void (^)(NSError *error))block{
    fitpolo701_main_safe(^{
        if (block) {
            NSError *error = [self getErrorWithCode:fitpolo701CharacteristicError message:@"characteristic error"];
            block(error);
        }
    });
}

+ (void)operationRequestDataErrorBlock:(void (^)(NSError *error))block{
    fitpolo701_main_safe(^{
        if (block) {
            NSError *error = [self getErrorWithCode:fitpolo701RequestPeripheralDataError message:@"request bracelet data error"];
            block(error);
        }
    });
}

+ (void)operationParamsErrorBlock:(void (^)(NSError *error))block{
    fitpolo701_main_safe(^{
        if (block) {
            NSError *error = [self getErrorWithCode:fitpolo701ParamsError message:@"input parameter error"];
            block(error);
        }
    });
}

+ (void)operationSetParamsErrorBlock:(void (^)(NSError *error))block{
    fitpolo701_main_safe(^{
        if (block) {
            NSError *error = [self getErrorWithCode:fitpolo701SetParamsError message:@"set parameter error"];
            block(error);
        }
    });
}

+ (void)operationGetPackageDataErrorBlock:(void (^)(NSError *error))block{
    fitpolo701_main_safe(^{
        if (block) {
            NSError *error = [self getErrorWithCode:fitpolo701GetPackageError message:@"get package error"];
            block(error);
        }
    });
}

+ (void)operationUpdateErrorBlock:(void (^)(NSError *error))block{
    fitpolo701_main_safe(^{
        if (block) {
            NSError *error = [self getErrorWithCode:fitpolo701UpdateError message:@"update failed"];
            block(error);
        }
    });
}

+ (void)operationSetParamsResult:(id)returnData
                        sucBlock:(void (^)(id returnData))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock{
    if (!fitpolo701ValidDict(returnData)) {
        [self operationSetParamsErrorBlock:failedBlock];
        return;
    }
    BOOL resultStatus = [returnData[@"result"][@"result"] boolValue];
    if (!resultStatus) {
        [self operationSetParamsErrorBlock:failedBlock];
        return ;
    }
    NSDictionary *resultDic = @{@"msg":@"success",
                                @"code":@"1",
                                @"result":@{},
                                };
    fitpolo701_main_safe(^{
        if (sucBlock) {
            sucBlock(resultDic);
        }
    });
}

#pragma mark - parser

+ (NSInteger)getDecimalWithHex:(NSString *)content range:(NSRange)range{
    if (!fitpolo701ValidStr(content)) {
        return 0;
    }
    if (range.location > content.length - 1 || range.length > content.length || (range.location + range.length > content.length)) {
        return 0;
    }
    return strtoul([[content substringWithRange:range] UTF8String],0,16);
}
+ (NSString *)getDecimalStringWithHex:(NSString *)content range:(NSRange)range{
    if (!fitpolo701ValidStr(content)) {
        return @"";
    }
    if (range.location > content.length - 1 || range.length > content.length || (range.location + range.length > content.length)) {
        return @"";
    }
    NSInteger decimalValue = strtoul([[content substringWithRange:range] UTF8String],0,16);
    return [NSString stringWithFormat:@"%ld",(long)decimalValue];
}

/**
 把originalArray数组按照range进行截取，生成一个新的数组并返回该数组

 @param originalArray 原数组
 @param range 截取范围
 @return 截取后生成的数组
 */
+ (NSArray *)interceptionOfArray:(NSArray *)originalArray subRange:(NSRange)range{
    if (!fitpolo701ValidArray(originalArray)) {
        return nil;
    }
    if (range.location > originalArray.count - 1 || range.length > originalArray.count || (range.location + range.length > originalArray.count)) {
        return nil;
    }
    NSMutableArray *desArray = [NSMutableArray array];
    for (NSInteger i = 0; i < range.length; i ++) {
        [desArray addObject:originalArray[range.location + i]];
    }
    return desArray;
}

/**
 对NSData进行CRC16的校验
 
 @param data 目标data
 @return CRC16校验码
 */
+ (NSData *)getCrc16VerifyCode:(NSData *)data{
    if (!fitpolo701ValidData(data)) {
        return nil;
    }
    NSInteger crcWord = 0xffff;
    Byte *dataArray = (Byte *)[data bytes];
    for (NSInteger i = 0; i < data.length; i ++) {
        Byte byte = dataArray[i];
        crcWord ^= (NSInteger)byte & 0x00ff;
        for (NSInteger j = 0; j < 8; j ++) {
            if ((crcWord & 0x0001) == 1) {
                crcWord = crcWord >> 1;
                crcWord = crcWord ^ 0xA001;
            }else{
                crcWord = (crcWord >> 1);
            }
        }
    }
    
    Byte crcL = (Byte)0xff & (crcWord >> 8);
    Byte crcH = (Byte)0xff & (crcWord);
    Byte arrayCrc[] = {crcH, crcL};
    NSData *dataCrc = [NSData dataWithBytes:arrayCrc length:sizeof(arrayCrc)];
    return dataCrc;
}

+ (NSString *)getAncsCommand:(fitpolo701AncsModel *)ancsModel{
    if (!ancsModel) {
        return nil;
    }
    //短信、电话、微信、qq、whatsapp、facebook、twitter、skype、snapchat、line
    unsigned long lowByte = 0;
    unsigned long highByte = 0;
    if (ancsModel.openSMS) lowByte |= 0x01;
    if (ancsModel.openPhone) lowByte |= 0x02;
    if (ancsModel.openWeChat) lowByte |= 0x04;
    if (ancsModel.openQQ) lowByte |= 0x08;
    if (ancsModel.openWhatsapp) lowByte |= 0x10;
    if (ancsModel.openFacebook) lowByte |= 0x20;
    if (ancsModel.openTwitter) lowByte |= 0x40;
    if (ancsModel.openSkype) lowByte |= 0x80;
    if (ancsModel.openSnapchat) highByte |= 0x01;
    if (ancsModel.openLine) highByte |= 0x02;
    NSString *lowString = [[NSString alloc] initWithFormat:@"%1lx",lowByte];
    if (lowString.length == 1) {
        lowString = [@"0" stringByAppendingString:lowString];
    }
    NSString *highString = [[NSString alloc] initWithFormat:@"%1lx",highByte];
    if (highString.length == 1) {
        highString = [@"0" stringByAppendingString:highString];
    }
    return [highString stringByAppendingString:lowString];
}

+ (fitpolo701AncsModel *)getAncsOptions:(NSString *)content{
    NSInteger high = [self getDecimalWithHex:content range:NSMakeRange(content.length - 4, 2)];
    NSInteger low = [self getDecimalWithHex:content range:NSMakeRange(content.length - 2, 2)];
    //短信、电话、微信、、、、、、
    fitpolo701AncsModel *model = [[fitpolo701AncsModel alloc] init];
    model.openSnapchat = ((high & 0x01) == 0x01);
    model.openLine = ((high & 0x02) == 0x02);
    model.openSkype = ((low & 0x80) == 0x80);
    model.openTwitter = ((low & 0x40) == 0x40);
    model.openFacebook = ((low & 0x20) == 0x20);
    model.openWhatsapp = ((low & 0x10) == 0x10);
    model.openQQ = ((low & 0x08) == 0x08);
    model.openWeChat = ((low & 0x04) == 0x04);
    model.openPhone = ((low & 0x02) == 0x02);
    model.openSMS = ((low & 0x01) == 0x01);
    return model;
}

+ (NSString *)getAlarmClockType:(fitpolo701AlarmClockType)clockType{
    switch (clockType) {
        case fitpolo701AlarmClockMedicine:
            return @"00";
        case fitpolo701AlarmClockDrink:
            return @"01";
        case fitpolo701AlarmClockNormal:
            return @"03";
        case fitpolo701AlarmClockSleep:
            return @"04";
        case fitpolo701AlarmClockExcise:
            return @"05";
        case fitpolo701AlarmClockSport:
            return @"06";
    }
}
+ (NSString *)getAlarlClockSetInfo:(fitpolo701StatusModel *)statusModel isOn:(BOOL)isOn{
    unsigned long byte = 0;
    if (statusModel.mondayIsOn) byte |= 0x01;
    if (statusModel.tuesdayIsOn) byte |= 0x02;
    if (statusModel.wednesdayIsOn) byte |= 0x04;
    if (statusModel.thursdayIsOn) byte |= 0x08;
    if (statusModel.fridayIsOn) byte |= 0x10;
    if (statusModel.saturdayIsOn) byte |= 0x20;
    if (statusModel.sundayIsOn) byte |= 0x40;
    if (isOn) byte |= 0x80;
    NSString *byteHexString = [NSString stringWithFormat:@"%1lx",byte];
    if (byteHexString.length == 1) {
        byteHexString = [@"0" stringByAppendingString:byteHexString];
    }
    return byteHexString;
}

+ (NSString *)getScreenDisplay:(fitpolo701ScreenDisplayModel *)displayModel{
    if (!displayModel) {
        return nil;
    }
    unsigned long byte = 1;
    //计步页面、心率页面、运动距离页面、卡路里页面、运动时间页面
    if (displayModel.turnOnStepPage) byte |= 0x02;
    if (displayModel.turnOnHeartRatePage) byte |= 0x04;
    if (displayModel.turnOnSportsDistancePage) byte |= 0x08;
    if (displayModel.turnOnCaloriesPage) byte |= 0x10;
    if (displayModel.turnOnSportsTimePage) byte |= 0x20;
    NSString *byteHexString = [NSString stringWithFormat:@"%1lx",byte];
    if (byteHexString.length == 1) {
        byteHexString = [@"0" stringByAppendingString:byteHexString];
    }
    return byteHexString;
}

+ (NSString *)hexStringFromData:(NSData *)sourceData{
    if (!fitpolo701ValidData(sourceData)) {
        return nil;
    }
    Byte *bytes = (Byte *)[sourceData bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[sourceData length];i++){
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

+ (NSString *)getTimeStringWithDate:(NSDate *)date{
    if (!date) {
        return nil;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm"];
    NSString *timeStamp = [formatter stringFromDate:date];
    if (!fitpolo701ValidStr(timeStamp)) {
        return nil;
    }
    NSArray *timeList = [timeStamp componentsSeparatedByString:@"-"];
    if (!fitpolo701ValidArray(timeList) || timeList.count != 5) {
        return nil;
    }
    if ([timeList[0] integerValue] < 2000 || [timeList[0] integerValue] > 2099) {
        return nil;
    }
    unsigned long yearValue = [timeList[0] integerValue] - 2000;
    NSString *hexTimeString = [NSString stringWithFormat:@"%1lx",yearValue];
    if (hexTimeString.length == 1) {
        hexTimeString = [@"0" stringByAppendingString:hexTimeString];
    }
    for (NSInteger i = 1; i < timeList.count; i ++) {
        unsigned long tempValue = [timeList[i] integerValue];
        NSString *hexTempStr = [NSString stringWithFormat:@"%1lx",tempValue];
        if (hexTempStr.length == 1) {
            hexTempStr = [@"0" stringByAppendingString:hexTempStr];
        }
        hexTimeString = [hexTimeString stringByAppendingString:hexTempStr];
    }
    return hexTimeString;
}

+ (BOOL)isMacAddress:(NSString *)macAddress{
    if (!fitpolo701ValidStr(macAddress)) {
        return NO;
    }
    NSString *regex = @"([A-Fa-f0-9]{2}-){5}[A-Fa-f0-9]{2}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:macAddress];
}
+ (BOOL)isMacAddressLowFour:(NSString *)lowFour{
    if (!fitpolo701ValidStr(lowFour)) {
        return NO;
    }
    NSString *regex = @"([A-Fa-f0-9]{2}-){1}[A-Fa-f0-9]{2}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:lowFour];
}
+ (BOOL)isUUIDString:(NSString *)uuid{
    if (!fitpolo701ValidStr(uuid)) {
        return NO;
    }
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:uuidPatternString
                                                                          options:NSRegularExpressionCaseInsensitive
                                                                            error:nil];
    NSInteger numberOfMatches = [regex numberOfMatchesInString:uuid
                                                       options:kNilOptions
                                                         range:NSMakeRange(0, uuid.length)];
    return (numberOfMatches > 0);
}

+ (BOOL)checkIdenty:(NSString *)identy{
    if ([self isMacAddressLowFour:identy]) {
        return YES;
    }
    if ([self isUUIDString:identy]) {
        return YES;
    }
    if ([self isMacAddress:identy]) {
        return YES;
    }
    return NO;
}

+ (NSData *)stringToData:(NSString *)dataString{
    if (!fitpolo701ValidStr(dataString)) {
        return nil;
    }
    if (!(dataString.length % 2 == 0)) {
        //必须是偶数个字符才是合法的
        return nil;
    }
    Byte bytes[255] = {0};
    NSInteger count = 0;
    for (int i =0; i < dataString.length; i+=2) {
        NSString *strByte = [dataString substringWithRange:NSMakeRange(i,2)];
        unsigned long red = strtoul([strByte UTF8String],0,16);
        Byte b =  (Byte) ((0xff & red) );//( Byte) 0xff&iByte;
        bytes[i/2+0] = b;
        count ++;
    }
    NSData * data = [NSData dataWithBytes:bytes length:count];
    return data;
}

+ (NSDictionary *)getHardwareParameters:(NSString *)content{
    //flash的状态
    NSString *flashStatus = [content substringWithRange:NSMakeRange(2, 2)];
    //当前反光阀值
    NSString *reflThreshold = [self getDecimalStringWithHex:content range:NSMakeRange(4, 4)];
    //当前反光值
    NSString *reflective = [self getDecimalStringWithHex:content range:NSMakeRange(8, 4)];
    //最后一次充电年
    NSString *year = [NSString stringWithFormat:@"%ld",(long)([self getDecimalWithHex:content range:NSMakeRange(12, 2)] + 2000)];
    //最后一次充电月
    NSString *month = [self getDecimalStringWithHex:content range:NSMakeRange(14, 2)];
    //最后一次充电日
    NSString *day = [self getDecimalStringWithHex:content range:NSMakeRange(16, 2)];
    //最后一次充电时
    NSString *hour = [self getDecimalStringWithHex:content range:NSMakeRange(18, 2)];
    //最后一次充电分
    NSString *min = [self getDecimalStringWithHex:content range:NSMakeRange(20, 2)];
    //手环最后一次充电时间
    NSString *chargingTime = [NSString stringWithFormat:@"%@-%@-%@-%@-%@",year,month,day,hour,min];
    //生产批次年
    NSString *productYear = [NSString stringWithFormat:@"%ld",(long)([self getDecimalWithHex:content range:NSMakeRange(22, 2)] + 2000)];
    //生产批次周
    NSString *productWeek = [self getDecimalStringWithHex:content range:NSMakeRange(24, 2)];
    BOOL ancsConnectStatus = [[content substringWithRange:NSMakeRange(26, 2)] isEqualToString:@"01"];
    NSDictionary *dic = @{
                          @"flashStatus":flashStatus,
                          @"reflThreshold":reflThreshold,
                          @"reflective":reflective,
                          @"chargingTime":chargingTime,
                          @"productYear":productYear,
                          @"productWeek":productWeek,
                          @"ancsConnectStatus":@(ancsConnectStatus)
                          };
    return dic;
}

+ (NSDictionary *)getMemoryData:(NSString *)content{
    NSString *stepCount = [self getDecimalStringWithHex:content range:NSMakeRange(0, 2)];
    NSString *battery = [self getDecimalStringWithHex:content range:NSMakeRange(4, 2)];
    NSString *tempString1 = [NSString stringWithFormat:@"解析后的memory数据:计步数据个数:%@", stepCount];
    NSString *tempString2 = [NSString stringWithFormat:@"解析后的memory数据:电池电量:%@", battery];
    [fitpolo701LogManager writeCommandToLocalFile:@[tempString1, tempString2] withSourceInfo:fitpolo701DataSourceDevice];
    return @{
             @"stepCount":stepCount,
             @"battery":battery,
             };
}

+ (NSDictionary *)getStepData:(NSString *)content{
    NSString *origData = [NSString stringWithFormat:@"手环返回计步数据:92%@",content];
    [fitpolo701LogManager writeCommandToLocalFile:@[origData] withSourceInfo:fitpolo701DataSourceDevice];
    NSString *SN = [self getDecimalStringWithHex:content range:NSMakeRange(0, 2)];
    NSString *year = [NSString stringWithFormat:@"%ld",(long)([self getDecimalWithHex:content range:NSMakeRange(2, 2)] + 2000)];
    NSString *month = [self getDecimalStringWithHex:content range:NSMakeRange(4, 2)];
    NSString *day = [self getDecimalStringWithHex:content range:NSMakeRange(6, 2)];
    NSString *stepNumber = [self getDecimalStringWithHex:content range:NSMakeRange(8, 8)];
    NSString *activityTime = [self getDecimalStringWithHex:content range:NSMakeRange(16, 4)];
    NSString *distance = [NSString stringWithFormat:@"%.1f",(float)([self getDecimalWithHex:content range:NSMakeRange(20, 4)] / 10.0)];
    NSString *calories = [self getDecimalStringWithHex:content range:NSMakeRange(24, 4)];
    
    NSString *tempString1 = [NSString stringWithFormat:@"解析后的计步数据:第%@条数据", SN];
    NSString *tempString2 = [NSString stringWithFormat:@"计步时间:%@-%@-%@",year,month,day];
    NSString *tempString3 = [NSString stringWithFormat:@"步数是:%@",stepNumber];
    NSString *tempString4 = [NSString stringWithFormat:@"运动时间:%@",activityTime];
    NSString *tempString5 = [NSString stringWithFormat:@"运动距离:%@",distance];
    NSString *tempString6 = [NSString stringWithFormat:@"消耗卡路里:%@",calories];
    [fitpolo701LogManager writeCommandToLocalFile:@[tempString1,tempString2,tempString3,tempString4,tempString5,tempString6]
                                   withSourceInfo:fitpolo701DataSourceDevice];
    return @{
             @"SN":SN,
             @"year":year,
             @"month":month,
             @"day":day,
             @"stepNumber":stepNumber,
             @"activityTime":activityTime,
             @"distance":distance,
             @"calories":calories,
             };
}

+ (NSDictionary *)getSleepIndexData:(NSString *)content{
    NSString *origData = [NSString stringWithFormat:@"返回的睡眠index数据:93%@", content];
    [fitpolo701LogManager writeCommandToLocalFile:@[origData] withSourceInfo:fitpolo701DataSourceDevice];
    NSString *SN = [self getDecimalStringWithHex:content range:NSMakeRange(0, 2)];
    NSString *startYear = [NSString stringWithFormat:@"%ld",(long)([self getDecimalWithHex:content range:NSMakeRange(2, 2)] + 2000)];
    NSString *startMonth = [self getDecimalStringWithHex:content range:NSMakeRange(4, 2)];
    NSString *startDay = [self getDecimalStringWithHex:content range:NSMakeRange(6, 2)];
    NSString *startHour = [self getDecimalStringWithHex:content range:NSMakeRange(8, 2)];
    NSString *startMin = [self getDecimalStringWithHex:content range:NSMakeRange(10, 2)];
    NSString *endYear = [NSString stringWithFormat:@"%ld",(long)([self getDecimalWithHex:content range:NSMakeRange(12, 2)] + 2000)];
    NSString *endMonth = [self getDecimalStringWithHex:content range:NSMakeRange(14, 2)];
    NSString *endDay = [self getDecimalStringWithHex:content range:NSMakeRange(16, 2)];
    NSString *endHour = [self getDecimalStringWithHex:content range:NSMakeRange(18, 2)];
    NSString *endMin = [self getDecimalStringWithHex:content range:NSMakeRange(20, 2)];
    NSString *deepSleepTime = [self getDecimalStringWithHex:content range:NSMakeRange(22, 4)];
    NSString *lightSleepTime = [self getDecimalStringWithHex:content range:NSMakeRange(26, 4)];
    NSString *awake = [self getDecimalStringWithHex:content range:NSMakeRange(30, 4)];
    
    NSString *tempString1 = [NSString stringWithFormat:@"解析后的睡眠index数据:第%@条index",SN];
    NSString *tempString2 = [NSString stringWithFormat:@"开始于%@-%@-%@ %@:%@",startYear,startMonth,startDay,startHour,startMin];
    NSString *tempString3 = [NSString stringWithFormat:@"结束于%@-%@-%@ %@:%@",endYear,endMonth,endDay,endHour,endMin];
    NSString *tempString4 = [NSString stringWithFormat:@"深睡时长:%@",deepSleepTime];
    NSString *tempString5 = [NSString stringWithFormat:@"浅睡时长:%@",lightSleepTime];
    NSString *tempString6 = [NSString stringWithFormat:@"清醒时长:%@",awake];
    [fitpolo701LogManager writeCommandToLocalFile:@[tempString1,tempString2,tempString3,tempString4,tempString5,tempString6]
                                   withSourceInfo:fitpolo701DataSourceDevice];
    
    return @{
             @"SN":SN,
             @"startYear":startYear,
             @"startMonth":startMonth,
             @"startDay":startDay,
             @"startHour":startHour,
             @"startMin":startMin,
             @"endYear":endYear,
             @"endMonth":endMonth,
             @"endDay":endDay,
             @"endHour":endHour,
             @"endMin":endMin,
             @"deepSleepTime":deepSleepTime,
             @"lightSleepTime":lightSleepTime,
             @"awake":awake,
             };
}

+ (NSDictionary *)getSleepRecordData:(NSString *)content{
    NSString *origData = [NSString stringWithFormat:@"返回的睡眠record数据:94%@", content];
    [fitpolo701LogManager writeCommandToLocalFile:@[origData] withSourceInfo:fitpolo701DataSourceDevice];
    //对应的睡眠详情长度
    NSInteger len = [self getDecimalWithHex:content range:NSMakeRange(4, 2)];
    if (len == 0) {
        return @{};
    }
    NSMutableArray *detailList = [NSMutableArray array];
    NSInteger index = 6;
    for (NSInteger i = 0; i < len; i ++) {
        NSString * hexStr = [content substringWithRange:NSMakeRange(index, 2)];
        NSArray * tempList = [self getSleepDetailList:hexStr];
        if (fitpolo701ValidArray(tempList)) {
            [detailList addObjectsFromArray:tempList];
        }
        index += 2;
    }
    NSString *SN = [self getDecimalStringWithHex:content range:NSMakeRange(0, 2)];
    NSString *fragmentSN = [self getDecimalStringWithHex:content range:NSMakeRange(2, 2)];
    
    NSString *tempString = @"";
    for (NSString *temp in detailList) {
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@" %@",temp]];
    }
    NSString *tempString1 = [NSString stringWithFormat:@"解析后的睡眠index数据:对应第%@条睡眠index数据",SN];
    NSString *tempString2 = [NSString stringWithFormat:@"本条数据index数据下面是第%@条record数据",fragmentSN];
    NSString *tempString3 = [NSString stringWithFormat:@"解析后的睡眠详情:%@",tempString];
    [fitpolo701LogManager writeCommandToLocalFile:@[tempString1,tempString2,tempString3,]
                                   withSourceInfo:fitpolo701DataSourceDevice];
    
    return @{
             @"SN":SN,
             @"fragmentSN":fragmentSN,
             @"detailList":detailList,
             };
}

+ (NSArray *)getHeartRateData:(NSString *)content{
    NSString *origData = [NSString stringWithFormat:@"手环心率数据数据:a8%@",content];
    [fitpolo701LogManager writeCommandToLocalFile:@[origData] withSourceInfo:fitpolo701DataSourceDevice];
    NSMutableArray *dataList = [NSMutableArray arrayWithCapacity:3];
    for (NSInteger i = 0; i < 3; i ++) {
        NSString *tempContent = [content substringWithRange:NSMakeRange(i * 12, 12)];
        NSString *year = [NSString stringWithFormat:@"%ld",(long)([self getDecimalWithHex:tempContent range:NSMakeRange(0, 2)] + 2000)];
        NSString *month = [self getDecimalStringWithHex:tempContent range:NSMakeRange(2, 2)];
        NSString *day = [self getDecimalStringWithHex:tempContent range:NSMakeRange(4, 2)];
        NSString *hour = [self getDecimalStringWithHex:tempContent range:NSMakeRange(6, 2)];
        NSString *min = [self getDecimalStringWithHex:tempContent range:NSMakeRange(8, 2)];
        NSString *heartRate = [self getDecimalStringWithHex:tempContent range:NSMakeRange(10, 2)];
        
        NSString *timeString = [NSString stringWithFormat:@"心率时间:%@-%@-%@ %@:%@",year,month,day,hour,min];
        NSString *heartRateString = [NSString stringWithFormat:@"心率值:%@",heartRate];
        [fitpolo701LogManager writeCommandToLocalFile:@[timeString,heartRateString]
                                       withSourceInfo:fitpolo701DataSourceDevice];
        [dataList addObject:@{
                              @"year":year,
                              @"month":month,
                              @"day":day,
                              @"hour":hour,
                              @"minute":min,
                              @"heartRate":heartRate
                              }];
    }
    return [NSArray arrayWithArray:dataList];
}

+ (NSDictionary *)getFirmwareVersion:(NSString *)content{
    NSString *origData = [NSString stringWithFormat:@"固件版本号数据:90%@",content];
    [fitpolo701LogManager writeCommandToLocalFile:@[origData] withSourceInfo:fitpolo701DataSourceDevice];
    NSString *major = [self getDecimalStringWithHex:content range:NSMakeRange(0, 2)];
    NSString *minor = [self getDecimalStringWithHex:content range:NSMakeRange(2, 2)];
    NSString *revision = [self getDecimalStringWithHex:content range:NSMakeRange(4, 2)];
    NSString *firmwareVersion = [NSString stringWithFormat:@"%@.%@.%@",major,minor,revision];
    NSString *tempString = [NSString stringWithFormat:@"固件版本号解析后的数据:%@",firmwareVersion];
    [fitpolo701LogManager writeCommandToLocalFile:@[tempString] withSourceInfo:fitpolo701DataSourceDevice];
    return @{
             @"firmwareVersion":firmwareVersion
             };
}

+ (NSArray *)getAlarmClockList:(NSString *)content{
    NSMutableArray *list = [NSMutableArray array];
    for (NSInteger i = 0; i < 4; i ++) {
        NSString *subContent = [content substringWithRange:NSMakeRange(i * 8, 8)];
        if (![[subContent substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"00"]) {
            //@"00000000"此类闹钟属于无效数据
            fitpolo701AlarmClockModel *clockModel = [[fitpolo701AlarmClockModel alloc] init];
            clockModel.clockType = [self getClockType:[subContent substringWithRange:NSMakeRange(0, 2)]];
            NSDictionary *dic = [self getClockStatusModelWithString:[subContent substringWithRange:NSMakeRange(2, 2)]];
            clockModel.statusModel = dic[@"statusModel"];
            clockModel.isOn = [dic[@"isOn"] boolValue];
            clockModel.hour = [self getDecimalWithHex:subContent range:NSMakeRange(4, 2)];
            clockModel.minutes = [self getDecimalWithHex:subContent range:NSMakeRange(6, 2)];
            [list addObject:clockModel];
        }
    }
    return [list mutableCopy];
}

+ (NSArray *)getSleepDataList:(NSArray *)indexList recordList:(NSArray *)recordList{
    if (!fitpolo701ValidArray(indexList) || !fitpolo701ValidArray(recordList)) {
        return nil;
    }
    NSMutableArray *resultArray = [NSMutableArray array];
    
    for (NSDictionary *dic in indexList) {
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        NSArray *sleepDetailList = [self getDetailSleepList:dic[@"SN"] recordList:recordList];
        [tempDic setObject:sleepDetailList forKey:@"detailedSleep"];
        [resultArray addObject:tempDic];
    }
    return [resultArray copy];
}

+ (NSDictionary *)getSedentaryRemindData:(NSString *)content{
    BOOL isOn = [[content substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"01"];
    NSString *startHour = [self getDecimalStringWithHex:content range:NSMakeRange(2, 2)];
    NSString *startMin = [self getDecimalStringWithHex:content range:NSMakeRange(4, 2)];
    NSString *endHour = [self getDecimalStringWithHex:content range:NSMakeRange(6, 2)];
    NSString *endMin = [self getDecimalStringWithHex:content range:NSMakeRange(8, 2)];
    return @{
             @"isOn":@(isOn),
             @"startHour":startHour,
             @"startMin":startMin,
             @"endHour":endHour,
             @"endMin":endMin,
             };
}

+ (NSDictionary *)getConfigurationParameters:(NSString *)content{
    NSString *unit = [content substringWithRange:NSMakeRange(0, 2)];
    NSString *timeFormat = [content substringWithRange:NSMakeRange(2, 2)];
    fitpolo701ScreenDisplayModel *displayModel = [self getScreenDisplayModelWithContent:[content substringWithRange:NSMakeRange(4, 2)]];
    BOOL remindLastScreenDisplay = [[content substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"01"];
    NSString *heartRateAcquisitionInterval = @"0";
    NSString *tempHeart = [content substringWithRange:NSMakeRange(8, 2)];
    if ([tempHeart isEqualToString:@"01"]) {
        heartRateAcquisitionInterval = @"10";
    }else if ([tempHeart isEqualToString:@"02"]){
        heartRateAcquisitionInterval = @"20";
    }else if ([tempHeart isEqualToString:@"03"]){
        heartRateAcquisitionInterval = @"30";
    }
    BOOL palmingBrightScreen = [[content substringWithRange:NSMakeRange(10, 2)] isEqualToString:@"00"];
    return @{
                @"unit":unit,
                @"timeFormat":timeFormat,
                @"screenDisplayModel":displayModel,
                @"remindLastScreenDisplay":@(remindLastScreenDisplay),
                @"heartRateAcquisitionInterval":heartRateAcquisitionInterval,
                @"palmingBrightScreen":@(palmingBrightScreen)
             };
}

+ (NSString *)getCommandType:(fitpolo701TaskOperationID)operationID{
    switch (operationID) {
        case fitpolo701VibrationOperation:
            return @"手环震动";
        case fitpolo701SetUnitOperation:
            return @"设置单位信息";
        case fitpolo701OpenANCSOperation:
            return @"开启ancs";
        case fitpolo701SetANCSOptionsOperation:
            return @"设置ancs通知选项";
        case fitpolo701SetDateOperation:
            return @"设置日期";
        case fitpolo701SetUserInfoOperation:
            return @"设置个人信息";
        case fitpolo701SetTimeFormatOperation:
            return @"设置时间进制格式";
        case fitpolo701OpenPalmingBrightScreenOperation:
            return @"设置翻腕亮屏";
        case fitpolo701SetAlarmClockOperation:
            return @"设置闹钟";
        case fitpolo701RemindLastScreenDisplayOperation:
            return @"设置上一次屏幕显示";
        case fitpolo701SetSedentaryRemindOperation:
            return @"设置久坐提醒";
        case fitpolo701SetHeartRateAcquisitionIntervalOperation:
            return @"设置心率采集间隔";
        case fitpolo701SetScreenDisplayOperation:
            return @"设置屏幕显示";
        case fitpolo701CloseANCSOperation:
            return @"关闭ancs通知";
        case fitpolo701GetMemoryDataOperation:
            return @"获取memory数据";
        case fitpolo701GetHardwareParametersOperation:
            return @"获取硬件参数";
        case fitpolo701GetFirmwareVersionOperation:
            return @"获取固件版本号";
        case fitpolo701GetInternalVersionOperation:
            return @"获取内部版本号";
        case fitpolo701GetStepDataOperation:
            return @"获取计步数据";
        case fitpolo701GetSleepIndexOperation:
            return @"获取睡眠index数据";
        case fitpolo701GetSleepRecordOperation:
            return @"获取睡眠record数据";
        case fitpolo701GetHeartDataOperation:
            return @"获取心率数据";
        case fitpolo701StartUpdateOperation:
            return @"开启手环升级";
        case fitpolo701GetANCSOptionsOperation:
            return @"请求ancs选项";
        case fitpolo701GetAlarmClockDataOperation:
            return @"请求闹钟数据";
        case fitpolo701GetSedentaryRemindOperation:
            return @"请求久坐提醒数据";
        case fitpolo701GetConfigurationParametersOperation:
            return @"请求设备配置参数";
        case fitpolo701DefaultTaskOperationID:
            return @"";
    }
}

#pragma mark - Private method
+ (NSArray *)getDetailSleepList:(NSString *)SN recordList:(NSArray *)recordList{
    NSMutableArray * tempList = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < recordList.count; i ++) {
        NSDictionary *recordDic = recordList[i];
        if ([recordDic[@"SN"] isEqualToString:SN]) {
            [tempList addObject:recordDic];
        }
    }
    NSArray *sortedArray = [tempList sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *dic1, NSDictionary *dic2){
        NSInteger index1 = [dic1[@"fragmentSN"] integerValue];
        NSInteger index2 = [dic2[@"fragmentSN"] integerValue];
        return [[NSNumber numberWithInteger:index1]
                compare:[NSNumber numberWithInteger:index2]];
    }];
    NSMutableArray *resultList = [NSMutableArray array];
    for (NSInteger m = 0; m < [sortedArray count]; m ++) {
        NSDictionary *dic = [sortedArray objectAtIndex:m];
        NSArray *list = dic[@"detailList"];
        if (fitpolo701ValidArray(list)) {
            [resultList addObjectsFromArray:list];
        }
    }
    
    return resultList;
}

+ (NSArray *)getSleepDetailList:(NSString *)detail{
    if (!fitpolo701ValidStr(detail) || detail.length != 2) {
        return nil;
    }
    NSDictionary *hexDic = @{
                             @"0":@"0000",@"1":@"0001",@"2":@"0010",
                             @"3":@"0011",@"4":@"0100",@"5":@"0101",
                             @"6":@"0110",@"7":@"0111",@"8":@"1000",
                             @"9":@"1001",@"A":@"1010",@"a":@"1010",
                             @"B":@"1011",@"b":@"1011",@"C":@"1100",
                             @"c":@"1100",@"D":@"1101",@"d":@"1101",
                             @"E":@"1110",@"e":@"1110",@"F":@"1111",
                             @"f":@"1111",
                             };
    NSString *binaryString = @"";
    for (int i=0; i<[detail length]; i++) {
        NSRange rage;
        rage.length = 1;
        rage.location = i;
        NSString *key = [detail substringWithRange:rage];
        binaryString = [NSString stringWithFormat:@"%@%@",
                        binaryString,
                        [NSString stringWithFormat:@"%@",[hexDic objectForKey:key]]];
        
    }
    if (binaryString.length != 8) {
        return nil;
    }
    NSMutableArray * list = [[NSMutableArray alloc] init];
    NSInteger index = 0;
    for (NSInteger i = 0; i < 4; i ++) {
        NSString * string = [binaryString substringWithRange:NSMakeRange(index, 2)];
        if ([string isEqualToString:@"11"]) {
            string = @"00";
        }
        [list addObject:string];
        index += 2;
    }
    NSMutableArray * resultArr = (NSMutableArray *)[[list reverseObjectEnumerator] allObjects];
    return resultArr;
}
//0x00:吃药;0x01:喝水;0x03:普通;0x04:睡觉;0x05:锻炼;0x06:跑步
+ (fitpolo701AlarmClockType)getClockType:(NSString *)content{
    if ([content isEqualToString:@"00"]) {
        return fitpolo701AlarmClockMedicine;
    }
    if ([content isEqualToString:@"01"]) {
        return fitpolo701AlarmClockDrink;
    }
    if ([content isEqualToString:@"03"]) {
        return fitpolo701AlarmClockNormal;
    }
    if ([content isEqualToString:@"04"]) {
        return fitpolo701AlarmClockSleep;
    }
    if ([content isEqualToString:@"05"]) {
        return fitpolo701AlarmClockExcise;
    }
    if ([content isEqualToString:@"06"]) {
        return fitpolo701AlarmClockSport;
    }
    return fitpolo701AlarmClockNormal;
}

//Bit0-Bit6：代表周一至周日，为真代表打开 Bit7：1代表打开闹钟，0代表关闭闹钟
+ (NSDictionary *)getClockStatusModelWithString:(NSString *)modelString{
    NSInteger statusValue = [self getDecimalWithHex:modelString range:NSMakeRange(0, 2)];
    fitpolo701StatusModel *statusModel = [[fitpolo701StatusModel alloc] init];
    statusModel.mondayIsOn = (statusValue & 0x01);
    statusModel.tuesdayIsOn = (statusValue & 0x02);
    statusModel.wednesdayIsOn = (statusValue & 0x04);
    statusModel.thursdayIsOn = (statusValue & 0x08);
    statusModel.fridayIsOn = (statusValue & 0x10);
    statusModel.saturdayIsOn = (statusValue & 0x20);
    statusModel.sundayIsOn = (statusValue & 0x40);
    
    return @{
             @"statusModel":statusModel,
             @"isOn":@(statusValue & 0x80),
             };
}

+ (fitpolo701ScreenDisplayModel *)getScreenDisplayModelWithContent:(NSString *)content{
    NSInteger screenValue = [self getDecimalWithHex:content range:NSMakeRange(0, 2)];
    fitpolo701ScreenDisplayModel *displayModel = [[fitpolo701ScreenDisplayModel alloc] init];
    displayModel.turnOnStepPage = (screenValue & 0x02);
    displayModel.turnOnHeartRatePage = (screenValue & 0x04);
    displayModel.turnOnSportsDistancePage = (screenValue & 0x08);
    displayModel.turnOnCaloriesPage = (screenValue & 0x10);
    displayModel.turnOnSportsTimePage = (screenValue & 0x20);
    return displayModel;
}

@end

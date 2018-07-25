//
//  Fitpolo701CentralManager.m
//  testSDK
//
//  Created by aa on 2018/3/13.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo701CentralManager.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "fitpolo701LogManager.h"
#import "fitpolo701Parser.h"
#import "CBPeripheral+fitpolo701Characteristic.h"
#import "fitpolo701TaskOperation.h"

@interface CBPeripheral (fitpolo701Scan)

/**
 703广播标识符为03,705广播标识符为05
 */
@property (nonatomic, copy, readonly)NSString *typeIdenty;

@property (nonatomic, copy, readonly)NSString *macAddress;

@property (nonatomic, copy, readonly)NSString *peripheralName;

/**
 根据广播内容设备peripheral相关信息
 
 @param advDic 扫描到的广播信息
 */
- (void)parseAdvData:(NSDictionary *)advDic;

/**
 扫描方式连接设备的情况下，需要判断当前设备是否是目标设备
 
 @param identifier 连接标识符
 @return YES:目标设备，NO:非目标设备
 */
- (BOOL)isTargetPeripheral:(NSString *)identifier;

@end

static const char *peripheralNameKey = "peripheralNameKey";
static const char *macAddressKey = "macAddressKey";
static const char *typeIdentyKey = "typeIdentyKey";

@implementation CBPeripheral (fitpolo701Scan)

- (void)parseAdvData:(NSDictionary *)advDic{
    if (!advDic || advDic.allValues.count == 0) {
        return;
    }
    NSData *data = advDic[CBAdvertisementDataManufacturerDataKey];
    if (data.length != 9) {
        return;
    }
    NSString *temp = data.description;
    temp = [temp stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"<" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@">" withString:@""];
    NSString *macAddress = [NSString stringWithFormat:@"%@-%@-%@-%@-%@-%@",
                            [temp substringWithRange:NSMakeRange(0, 2)],
                            [temp substringWithRange:NSMakeRange(2, 2)],
                            [temp substringWithRange:NSMakeRange(4, 2)],
                            [temp substringWithRange:NSMakeRange(6, 2)],
                            [temp substringWithRange:NSMakeRange(8, 2)],
                            [temp substringWithRange:NSMakeRange(10, 2)]];
    NSString *deviceType = [temp substringWithRange:NSMakeRange(12, 2)];
    if (macAddress) {
        objc_setAssociatedObject(self, &macAddressKey, macAddress, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    if (deviceType) {
        objc_setAssociatedObject(self, &typeIdentyKey, deviceType, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    if (advDic[CBAdvertisementDataLocalNameKey]) {
        objc_setAssociatedObject(self, &peripheralNameKey, advDic[CBAdvertisementDataLocalNameKey], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

/**
 扫描方式连接设备的情况下，需要判断当前设备是否是目标设备
 
 @param identifier 连接标识符
 @return YES:目标设备，NO:非目标设备
 */
- (BOOL)isTargetPeripheral:(NSString *)identifier{
    if (!identifier) {
        return NO;
    }
    NSString *macLow = [[self.macAddress lowercaseString] substringWithRange:NSMakeRange(12, 5)];
    if ([identifier isEqualToString:macLow]) {
        return YES;
    }
    if ([identifier isEqualToString:[self.macAddress lowercaseString]]) {
        return YES;
    }
    if ([identifier isEqualToString:self.identifier.UUIDString]) {
        return YES;
    }
    return NO;
}

- (NSString *)peripheralName{
    return objc_getAssociatedObject(self, &peripheralNameKey);
}

- (NSString *)macAddress{
    return objc_getAssociatedObject(self, &macAddressKey);
}

- (NSString *)typeIdenty{
    return objc_getAssociatedObject(self, &typeIdentyKey);
}
@end

typedef NS_ENUM(NSInteger, currentManagerAction) {
    currentManagerActionDefault,
    currentManagerActionScan,
    currentManagerActionConnectPeripheral,
    currentManagerActionConnectPeripheralWithScan,
};

static NSInteger const scanConnectMacCount = 2;
NSString *const fitpolo701PeripheralConnectStateChanged = @"fitpolo701PeripheralConnectStateChanged";
//外设固件升级结果通知,由于升级固件采用的是无应答定时器发送数据包，所以当产生升级结果的时候，需要靠这个通知来结束升级过程
NSString *const fitpolo701PeripheralUpdateResultNotification = @"fitpolo701PeripheralUpdateResultNotification";

static fitpolo701CentralManager *manager = nil;
static dispatch_once_t onceToken;

@interface fitpolo701CentralManager()<CBCentralManagerDelegate, CBPeripheralDelegate>

/**
 中心设备
 */
@property (nonatomic, strong)CBCentralManager *centralManager;

@property (nonatomic, strong)CBPeripheral *connectedPeripheral;

@property (nonatomic, strong)dispatch_queue_t centralManagerQueue;

/**
 扫描定时器
 */
@property (nonatomic, strong)dispatch_source_t scanTimer;

/**
 连接定时器，超过指定时间将会视为连接失败
 */
@property (nonatomic, strong)dispatch_source_t connectTimer;

@property (nonatomic, copy)fitpolo701ConnectPeripheralFailedBlock connectFailBlock;

@property (nonatomic, copy)fitpolo701ConnectPeripheralSuccessBlock connectSucBlock;

/**
 当前运行方式
 */
@property (nonatomic, assign)currentManagerAction managerAction;

/**
 完成了一个扫描周期
 */
@property (nonatomic, assign)BOOL scanTimeout;

/**
 用扫描方式连接设备的时候，未扫到设备次数，超过指定次数需要结束扫描，连接设备失败
 */
@property (nonatomic, assign)NSInteger scanConnectCount;

/**
 扫描方式连接设备时候的标识符，UUID、mac地址、mac地址低四位
 */
@property (nonatomic, copy)NSString *identifier;

@property (nonatomic, assign)fitpolo701ConnectStatus connectStatus;

@property (nonatomic, assign)fitpolo701CentralManagerState centralStatus;

@property (nonatomic, strong)NSOperationQueue *operationQueue;

@end

@implementation fitpolo701CentralManager

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"中心销毁");
}

//生成唯一的实例
- (instancetype) initInstance {
    if (self = [super init]) {
        _centralManagerQueue = dispatch_queue_create("moko.com.centralManager", DISPATCH_QUEUE_SERIAL);
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:_centralManagerQueue];
    }
    return self;
}

+ (void)singletonDestroyed{
    onceToken = 0; // 只有置成0,GCD才会认为它从未执行过.它默认为0.这样才能保证下次再次调用shareInstance的时候,再次创建对象.
    manager = nil;
}

+ (fitpolo701CentralManager *)sharedInstance{
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[super alloc] initInstance];
        }
    });
    return manager;
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    fitpolo701CentralManagerState managerState = fitpolo701CentralManagerStateUnable;
    if (central.state == CBCentralManagerStatePoweredOn) {
        managerState = fitpolo701CentralManagerStateEnable;
    }
    self.centralStatus = managerState;
    if ([self.managerStateDelegate respondsToSelector:@selector(fitpolo701CentralStateChanged:manager:)]) {
        fitpolo701_main_safe(^{
            [self.managerStateDelegate fitpolo701CentralStateChanged:managerState manager:manager];
        });
    }
    if (central.state == CBCentralManagerStatePoweredOn) {
        return;
    }
    if (self.connectedPeripheral) {
        self.connectedPeripheral = nil;
        [self updateManagerStateConnectState:fitpolo701ConnectStatusDisconnect];
        [self.operationQueue cancelAllOperations];
    }
    if (self.managerAction == currentManagerActionDefault) {
        return;
    }
    if (self.managerAction == currentManagerActionScan) {
        self.managerAction = currentManagerActionDefault;
        [self.centralManager stopScan];
        fitpolo701_main_safe(^{
            if ([self.scanDelegate respondsToSelector:@selector(fitpolo701CentralStopScan:)]) {
                [self.scanDelegate fitpolo701CentralStopScan:manager];
            }
        });
        return;
    }
    if (self.managerAction == currentManagerActionConnectPeripheralWithScan) {
        [self.centralManager stopScan];
    }
    [self connectPeripheralFailed];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    dispatch_async(_centralManagerQueue, ^{
        [self scanNewPeripheral:peripheral advDic:advertisementData];
    });
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    self.connectedPeripheral = peripheral;
    self.connectedPeripheral.delegate = self;
    [self.connectedPeripheral discoverServices:@[[CBUUID UUIDWithString:@"FFC0"]]];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    [self connectPeripheralFailed];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"断开连接");
    self.connectedPeripheral = nil;
    [self updateManagerStateConnectState:fitpolo701ConnectStatusDisconnect];
    [self.operationQueue cancelAllOperations];
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        [self connectPeripheralFailed];
        return;
    }
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FFC0"]]) {
            //通用服务
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"FFC1"],
                                                  [CBUUID UUIDWithString:@"FFC2"]]
                                     forService:service];
        }
        break;
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        [self connectPeripheralFailed];
        return;
    }
    [self.connectedPeripheral update701CharacteristicsForService:service];
    if ([self.connectedPeripheral fitpolo701ConnectSuccess]) {
        [self connectPeripheralSuccess];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"read data from peripheral error:%@", [error localizedDescription]);
        return;
    }
    NSString *readData = [fitpolo701Parser hexStringFromData:characteristic.value];
    if (readData.length == 4) {
        NSString *header = [readData substringWithRange:NSMakeRange(0, 2)];
        if ([header isEqualToString:@"a7"]) {
            NSString *content = [readData substringWithRange:NSMakeRange(2, 2)];
            NSString *origData = [NSString stringWithFormat:@"手环升级结果数据:a7%@",content];
            [fitpolo701LogManager writeCommandToLocalFile:@[origData] withSourceInfo:fitpolo701DataSourceDevice];
            //抛出升级结果通知，@"00"成功@"01"超时@"02"校验码错误@"03"文件错误
            [[NSNotificationCenter defaultCenter] postNotificationName:fitpolo701PeripheralUpdateResultNotification
                                                                object:nil
                                                              userInfo:@{@"updateResult" : content}];
            return;
        }
    }
    
    @synchronized(self.operationQueue) {
        NSArray *operations = [self.operationQueue.operations copy];
        for (fitpolo701TaskOperation *operation in operations) {
            if (operation.executing) {
                [operation peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:NULL];
                break;
            }
        }
    }
}

#pragma mark - Public method
- (void)startScanPeripheral{
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        //蓝牙状态不可用
        return;
    }
    self.managerAction = currentManagerActionScan;
    if ([self.scanDelegate respondsToSelector:@selector(fitpolo701CentralStartScan:)]) {
        fitpolo701_main_safe(^{
            [self.scanDelegate fitpolo701CentralStartScan:manager];
        });
    }
    //日志
    [fitpolo701LogManager writeCommandToLocalFile:@[@"开始扫描"] withSourceInfo:fitpolo701DataSourceAPP];
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FFC0"]] options:nil];
}

/**
 停止扫描
 */
- (void)stopScan{
    [self.centralManager stopScan];
    self.managerAction = currentManagerActionDefault;
    if ([self.scanDelegate respondsToSelector:@selector(fitpolo701CentralStopScan:)]) {
        fitpolo701_main_safe(^{
            [self.scanDelegate fitpolo701CentralStopScan:manager];
        });
    }
}

/**
 根据标识符和连接方式来连接指定的外设
 
 @param identifier 要连接外设的标识符,目前支持设备UUID、设备mac地址(xx-xx-xx-xx-xx-xx)、设备mac地址低四位(xx-xx)三种连接方式。
 @param successBlock 连接设备成功回调
 @param failedBlock 连接设备失败回调
 */
- (void)connectPeripheralWithIdentifier:(NSString *)identifier
                    connectSuccessBlock:(fitpolo701ConnectPeripheralSuccessBlock)successBlock
                       connectFailBlock:(fitpolo701ConnectPeripheralFailedBlock)failedBlock{
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        //蓝牙状态不可用
        [fitpolo701Parser operationCentralBlePowerOffBlock:failedBlock];
        return;
    }
    if (![fitpolo701Parser checkIdenty:identifier]) {
        //参数错误
        [fitpolo701Parser operationConnectFailedBlock:failedBlock];
        return;
    }
    fitpolo701WS(weakSelf);
    [self connectWithIdentifier:identifier successBlock:^(CBPeripheral *connectedPeripheral, NSString *macAddress, NSString *peripheralName) {
        if (successBlock) {
            successBlock(connectedPeripheral, macAddress, peripheralName);
        }
        [weakSelf clearConnectBlock];
    } failBlock:^(NSError *error) {
        if (failedBlock) {
            failedBlock(error);
        }
        [weakSelf clearConnectBlock];
    }];
}

/**
 连接指定设备
 
 @param peripheral 目标设备
 @param connectSuccessBlock 连接成功回调
 @param connectFailedBlock 连接失败回调
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral
      connectSuccessBlock:(fitpolo701ConnectPeripheralSuccessBlock)connectSuccessBlock
       connectFailedBlock:(fitpolo701ConnectPeripheralFailedBlock)connectFailedBlock{
    if (!peripheral) {
        [fitpolo701Parser operationConnectFailedBlock:connectFailedBlock];
        return;
    }
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        //蓝牙状态不可用
        [fitpolo701Parser operationCentralBlePowerOffBlock:connectFailedBlock];
        return;
    }
    fitpolo701WS(weakSelf);
    [self connectWithPeripheral:peripheral sucBlock:^(CBPeripheral *connectedPeripheral, NSString *macAddress, NSString *peripheralName) {
        if (connectSuccessBlock) {
            connectSuccessBlock(connectedPeripheral, macAddress, peripheralName);
        }
        [weakSelf clearConnectBlock];
    } failedBlock:^(NSError *error) {
        if (connectFailedBlock) {
            connectFailedBlock(error);
        }
        [weakSelf clearConnectBlock];
    }];
}

/**
 断开当前连接的外设
 */
- (void)disconnectConnectedPeripheral{
    if (!self.connectedPeripheral || self.centralManager.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    [self.centralManager cancelPeripheralConnection:self.connectedPeripheral];
    self.connectedPeripheral = nil;
    self.managerAction = currentManagerActionDefault;
    [self updateManagerStateConnectState:fitpolo701ConnectStatusDisconnect];
}

#pragma mark - task
#pragma mark - 数据通信处理方法
- (void)sendCommandToPeripheral:(NSString *)commandData{
    if (!self.connectedPeripheral || !fitpolo701ValidStr(commandData) || !self.connectedPeripheral.commandSend) {
        return;
    }
    NSData *data = [fitpolo701Parser stringToData:commandData];
    if (!fitpolo701ValidData(data)) {
        return;
    }
    [self.connectedPeripheral writeValue:data
                       forCharacteristic:self.connectedPeripheral.commandSend
                                    type:CBCharacteristicWriteWithoutResponse];
}

- (void)writeDataToLog:(NSString *)commandData operation:(fitpolo701TaskOperationID)operationID{
    if (!fitpolo701ValidStr(commandData)) {
        return;
    }
    NSString *commandType = [fitpolo701Parser getCommandType:operationID];
    if (!fitpolo701ValidStr(commandType)) {
        return;
    }
    NSString *string = [NSString stringWithFormat:@"%@:%@",commandType,commandData];
    [fitpolo701LogManager writeCommandToLocalFile:@[string] withSourceInfo:fitpolo701DataSourceAPP];
}

- (BOOL)sendUpdateData:(NSData *)updateData{
    if (!self.connectedPeripheral || !self.connectedPeripheral.commandSend) {
        return NO;
    }
    if (!fitpolo701ValidData(updateData)) {
        return NO;
    }
    [self.connectedPeripheral writeValue:updateData
                       forCharacteristic:self.connectedPeripheral.commandSend
                                    type:CBCharacteristicWriteWithoutResponse];
    NSString *string = [NSString stringWithFormat:@"%@:%@",@"固件升级数据",[fitpolo701Parser hexStringFromData:updateData]];
    [fitpolo701LogManager writeCommandToLocalFile:@[string] withSourceInfo:fitpolo701DataSourceAPP];
    return YES;
}

/**
 添加一个通信任务(app-->peripheral)到队列
 
 @param operationID 任务ID
 @param resetNum 是否需要由外设返回通信数据总条数
 @param commandData 通信数据
 @param successBlock 通信成功回调
 @param failureBlock 通信失败回调
 */
- (void)addTaskWithTaskID:(fitpolo701TaskOperationID)operationID
                 resetNum:(BOOL)resetNum
              commandData:(NSString *)commandData
             successBlock:(fitpolo701CommunicationSuccessBlock)successBlock
             failureBlock:(fitpolo701CommunicationFailedBlock)failureBlock{
    
    fitpolo701TaskOperation *operation = [self generateOperationWithOperationID:operationID
                                                                       resetNum:resetNum
                                                                    commandData:commandData
                                                                   successBlock:successBlock
                                                                   failureBlock:failureBlock];
    if (!operation) {
        return;
    }
    [self.operationQueue addOperation:operation];
}

/**
 添加一个通信任务(app-->peripheral)到队列,当获任务结束只获取到部分数据的时候，返回这部分数据到成功回调
 
 @param operationID 任务ID
 @param commandData 通信数据
 @param successBlock 通信成功回调
 @param failureBlock 通信失败回调
 */
- (void)addNeedPartOfDataTaskWithTaskID:(fitpolo701TaskOperationID)operationID
                            commandData:(NSString *)commandData
                           successBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                           failureBlock:(fitpolo701CommunicationFailedBlock)failureBlock{
    fitpolo701TaskOperation *operation = [self generateOperationWithOperationID:operationID
                                                                       resetNum:YES
                                                                    commandData:commandData
                                                                   successBlock:successBlock
                                                                   failureBlock:failureBlock];
    if (!operation) {
        return;
    }
    SEL selNeedPartOfData = sel_registerName("needPartOfData:");
    if ([operation respondsToSelector:selNeedPartOfData]) {
        ((void (*)(id, SEL, NSNumber*))(void *) objc_msgSend)((id)operation, selNeedPartOfData, @(YES));
    }
    [self.operationQueue addOperation:operation];
}

/**
 添加一个通信任务(app-->peripheral)到队列,该任务需要设置本次通信数据条数
 
 @param operationID 任务ID
 @param number 设置的数据条数
 @param commandData 通信命令
 @param successBlock 通信成功回调
 @param failureBlock 通信失败回调
 */
- (void)addNeedResetNumTaskWithTaskID:(fitpolo701TaskOperationID)operationID
                               number:(NSInteger)number
                          commandData:(NSString *)commandData
                         successBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                         failureBlock:(fitpolo701CommunicationFailedBlock)failureBlock{
    if (number < 1) {
        return;
    }
    fitpolo701TaskOperation *operation = [self generateOperationWithOperationID:operationID
                                                                       resetNum:NO
                                                                    commandData:commandData
                                                                   successBlock:successBlock
                                                                   failureBlock:failureBlock];
    SEL setNum = sel_registerName("setRespondCount:");
    NSString *numberString = [NSString stringWithFormat:@"%ld",(long)number];
    if ([operation respondsToSelector:setNum]) {
        ((void (*)(id, SEL, NSString*))(void *) objc_msgSend)((id)operation, setNum, numberString);
    }
    if (!operation) {
        return;
    }
    [self.operationQueue addOperation:operation];
}

#pragma mark - Private method
- (void)connectWithPeripheral:(CBPeripheral *)peripheral
                     sucBlock:(fitpolo701ConnectPeripheralSuccessBlock)sucBlock
                  failedBlock:(fitpolo701ConnectPeripheralFailedBlock)failedBlock{
    if (self.connectedPeripheral) {
        [self.centralManager cancelPeripheralConnection:self.connectedPeripheral];
        [self.operationQueue cancelAllOperations];
    }
    self.connectedPeripheral = nil;
    self.connectedPeripheral = peripheral;
    self.managerAction = currentManagerActionConnectPeripheral;
    self.connectSucBlock = sucBlock;
    self.connectFailBlock = failedBlock;
    [self centralConnectPeripheral:peripheral];
}

- (void)connectWithIdentifier:(NSString *)identifier
                 successBlock:(fitpolo701ConnectPeripheralSuccessBlock)successBlock
                    failBlock:(fitpolo701ConnectPeripheralFailedBlock)failedBlock{
    if (self.connectedPeripheral) {
        [self.centralManager cancelPeripheralConnection:self.connectedPeripheral];
        [self.operationQueue cancelAllOperations];
    }
    self.connectedPeripheral = nil;
    self.identifier = [identifier lowercaseString];
    self.managerAction = currentManagerActionConnectPeripheralWithScan;
    self.connectSucBlock = successBlock;
    self.connectFailBlock = failedBlock;
    //通过扫描方式连接设备的时候，开始扫描应该视为开始连接
    [self updateManagerStateConnectState:fitpolo701ConnectStatusConnecting];
    [self startConnectPeripheralWithScan];
}

- (void)startConnectPeripheralWithScan{
    [self.centralManager stopScan];
    self.scanTimeout = NO;
    self.scanTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,dispatch_get_global_queue(0, 0));
    //开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 5.0 * NSEC_PER_SEC);
    //间隔时间
    uint64_t interval = 5.0 * NSEC_PER_SEC;
    dispatch_source_set_timer(self.scanTimer, start, interval, 0);
    fitpolo701WS(weakSelf);
    dispatch_source_set_event_handler(self.scanTimer, ^{
        [weakSelf scanTimerTimeoutProcess];
    });
    dispatch_resume(self.scanTimer);
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FFC0"]] options:nil];
}
#pragma mark - Action method

- (void)resetOriSettings{
    if (self.connectTimer) {
        dispatch_cancel(self.connectTimer);
    }
    if (self.scanTimer) {
        dispatch_cancel(self.scanTimer);
    }
    if (self.managerAction == currentManagerActionConnectPeripheralWithScan) {
        [self.centralManager stopScan];
    }
    self.managerAction = currentManagerActionDefault;
    self.scanTimeout = NO;
    self.scanConnectCount = 0;
}

- (void)connectPeripheralFailed{
    [self resetOriSettings];
    if (self.connectedPeripheral) {
        [self.centralManager cancelPeripheralConnection:self.connectedPeripheral];
        self.connectedPeripheral.delegate = nil;
    }
    self.connectedPeripheral = nil;
    [self updateManagerStateConnectState:fitpolo701ConnectStatusConnectedFailed];
    [fitpolo701Parser operationConnectFailedBlock:self.connectFailBlock];
}

- (void)connectPeripheralSuccess{
    [self resetOriSettings];
    [self updateManagerStateConnectState:fitpolo701ConnectStatusConnected];
    NSString *tempString1 = [NSString stringWithFormat:@"连接的设备名字:%@",self.connectedPeripheral.peripheralName];
    NSString *tempString2 = [NSString stringWithFormat:@"设备UUID:%@",self.connectedPeripheral.identifier.UUIDString];
    NSString *tempString3 = [NSString stringWithFormat:@"设备MAC地址:%@",self.connectedPeripheral.macAddress];
    [fitpolo701LogManager writeCommandToLocalFile:@[tempString1,
                                                    tempString2,
                                                    tempString3]
                                   withSourceInfo:fitpolo701DataSourceAPP];
    fitpolo701_main_safe(^{
        if (self.connectSucBlock) {
            self.connectSucBlock(self.connectedPeripheral, self.connectedPeripheral.macAddress, self.connectedPeripheral.peripheralName);
        }
    });
}

- (void)clearConnectBlock{
    if (self.connectSucBlock) {
        self.connectSucBlock = nil;
    }
    if (self.connectFailBlock) {
        self.connectFailBlock = nil;
    }
}

#pragma mark - Process method
- (void)scanTimerTimeoutProcess{
    [self.centralManager stopScan];
    if (self.managerAction != currentManagerActionConnectPeripheralWithScan) {
        return;
    }
    self.scanTimeout = YES;
    self.scanConnectCount ++;
    //扫描方式来连接设备
    if (self.scanConnectCount > scanConnectMacCount) {
        //如果扫描连接超时，则直接连接失败，停止扫描
        [self connectPeripheralFailed];
        return;
    }
    //如果小于最大的扫描连接次数，则开启下一轮扫描
    self.scanTimeout = NO;
    [fitpolo701LogManager writeCommandToLocalFile:@[@"开启新一轮扫描设备去连接"] withSourceInfo:fitpolo701DataSourceAPP];
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FFC0"]] options:nil];
}

- (void)initConnectTimer{
    dispatch_queue_t connectQueue = dispatch_queue_create("connectPeripheralQueue", DISPATCH_QUEUE_CONCURRENT);
    self.connectTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,connectQueue);
    //开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 20 * NSEC_PER_SEC);
    //间隔时间
    uint64_t interval = 20 * NSEC_PER_SEC;
    dispatch_source_set_timer(self.connectTimer, start, interval, 0);
    fitpolo701WS(weakSelf);
    dispatch_source_set_event_handler(self.connectTimer, ^{
        [weakSelf connectPeripheralFailed];
    });
    dispatch_resume(self.connectTimer);
}

- (void)centralConnectPeripheral:(CBPeripheral *)peripheral{
    if (!peripheral) {
        return;
    }
    if (self.scanTimer) {
        dispatch_cancel(self.scanTimer);
    }
    [self.centralManager stopScan];
    [self updateManagerStateConnectState:fitpolo701ConnectStatusConnecting];
    [self initConnectTimer];
    [self.centralManager connectPeripheral:peripheral options:@{}];
}

#pragma mark - delegate method process

- (void)scanNewPeripheral:(CBPeripheral *)peripheral advDic:(NSDictionary *)advDic{
    if (self.managerAction == currentManagerActionDefault || !peripheral || !fitpolo701ValidDict(advDic)) {
        return;
    }
    [peripheral parseAdvData:advDic];
    if (![self isRequirementsPeripheral:peripheral]) {
        return;
    }
    if (self.managerAction == currentManagerActionScan) {
        //扫描情况下
        if ([self.scanDelegate respondsToSelector:@selector(fitpolo701CentralScanningNewPeripheral:macAddress:peripheralName:centralManager:)]) {
            fitpolo701_main_safe(^{
                [self.scanDelegate fitpolo701CentralScanningNewPeripheral:peripheral
                                                               macAddress:peripheral.macAddress
                                                           peripheralName:peripheral.peripheralName
                                                           centralManager:manager];
            });
        }
        return;
    }
    if (self.managerAction != currentManagerActionConnectPeripheralWithScan
        || self.scanTimeout
        || self.scanConnectCount > 2) {
        return;
    }
    if (![peripheral isTargetPeripheral:self.identifier]) {
        return;
    }
    self.connectedPeripheral = peripheral;
    //开始连接目标设备
    [self centralConnectPeripheral:peripheral];
}

/**
 扫描到的设备是否符合要求
 
 @param peripheral 扫描到的设备
 @return YES符合，NO不符合
 */
- (BOOL)isRequirementsPeripheral:(CBPeripheral *)peripheral{
    if (!peripheral || !fitpolo701ValidStr(peripheral.typeIdenty)) {
        return NO;
    }
    BOOL canNext = NO;
    if ([peripheral.typeIdenty isEqualToString:@"02"]) {
        //701
        canNext = YES;
    }
    if (canNext) {
        NSString *name = [NSString stringWithFormat:@"扫描到的设备名字:%@",
                          peripheral.peripheralName];
        NSString *uuid = [NSString stringWithFormat:@"设备UUID:%@",
                          peripheral.identifier.UUIDString];
        NSString *mac = [NSString stringWithFormat:@"设备MAC地址:%@",
                         peripheral.macAddress];
        [fitpolo701LogManager writeCommandToLocalFile:@[name,uuid,mac] withSourceInfo:fitpolo701DataSourceAPP];
    }
    return canNext;
}

- (void)updateManagerStateConnectState:(fitpolo701ConnectStatus)state{
    self.connectStatus = state;
    [[NSNotificationCenter defaultCenter] postNotificationName:fitpolo701PeripheralConnectStateChanged object:nil];
    if ([self.managerStateDelegate respondsToSelector:@selector(fitpolo701PeripheralConnectStateChanged:manager:)]) {
        fitpolo701_main_safe(^{
            [self.managerStateDelegate fitpolo701PeripheralConnectStateChanged:state manager:manager];
        });
    }
}

#pragma mark - task process

- (BOOL)canSendData{
    if (!self.connectedPeripheral) {
        return NO;
    }
    return (self.connectedPeripheral.state == CBPeripheralStateConnected);
}

- (fitpolo701TaskOperation *)generateOperationWithOperationID:(fitpolo701TaskOperationID)operationID
                                                     resetNum:(BOOL)resetNum
                                                  commandData:(NSString *)commandData
                                                 successBlock:(fitpolo701CommunicationSuccessBlock)successBlock
                                                 failureBlock:(fitpolo701CommunicationFailedBlock)failureBlock{
    if (![self canSendData]) {
        [fitpolo701Parser operationDisconnectedErrorBlock:failureBlock];
        return nil;
    }
    if (!fitpolo701ValidStr(commandData)) {
        [fitpolo701Parser operationParamsErrorBlock:failureBlock];
        return nil;
    }
    if (!self.connectedPeripheral.commandSend) {
        [fitpolo701Parser operationCharacteristicErrorBlock:failureBlock];
        return nil;
    }
    fitpolo701WS(weakSelf);
    fitpolo701TaskOperation *operation = [[fitpolo701TaskOperation alloc] initOperationWithID:operationID resetNum:resetNum commandBlock:^{
        [weakSelf sendCommandToPeripheral:commandData];
        [weakSelf writeDataToLog:commandData operation:operationID];
    } completeBlock:^(NSError *error, fitpolo701TaskOperationID operationID, id returnData) {
        if (error) {
            fitpolo701_main_safe(^{
                if (failureBlock) {
                    failureBlock(error);
                }
            });
            return ;
        }
        if (!returnData) {
            [fitpolo701Parser operationRequestDataErrorBlock:failureBlock];
            return ;
        }
        NSString *lev = returnData[fitpolo701DataStatusLev];
        if ([lev isEqualToString:@"1"]) {
            //通用无附加信息的
            NSArray *dataList = (NSArray *)returnData[fitpolo701DataInformation];
            if (!fitpolo701ValidArray(dataList)) {
                [fitpolo701Parser operationRequestDataErrorBlock:failureBlock];
                return;
            }
            NSDictionary *resultDic = @{@"msg":@"success",
                                        @"code":@"1",
                                        @"result":(dataList.count == 1 ? dataList[0] : dataList),
                                        };
            fitpolo701_main_safe(^{
                if (successBlock) {
                    successBlock(resultDic);
                }
            });
            return;
        }
        //对于有附加信息的
        if (![lev isEqualToString:@"2"]) {
            //
            return;
        }
        NSDictionary *resultDic = @{@"msg":@"success",
                                    @"code":@"1",
                                    @"result":returnData[fitpolo701DataInformation],
                                    };
        fitpolo701_main_safe(^{
            if (successBlock) {
                successBlock(resultDic);
            }
        });
    }];
    return operation;
}

#pragma mark - setter & getter
- (NSOperationQueue *)operationQueue{
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    return _operationQueue;
}

@end


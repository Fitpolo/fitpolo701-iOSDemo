
#import <CoreBluetooth/CoreBluetooth.h>
#import "fitpolo701EnumerateDefine.h"

static NSString * const fitpolo701CustomErrorDomain = @"com.moko.fitpoloBluetoothSDK";

#define fitpolo701_main_safe(block)\
if ([NSThread isMainThread]) {\
    block();\
} else {\
    dispatch_async(dispatch_get_main_queue(), block);\
}

#define fitpolo701ConnectError(block)\
if(block){\
    fitpolo701_main_safe(^{\
        NSError *error = [[NSError alloc] initWithDomain:fitpolo701CustomErrorDomain\
                        code:fitpolo701PeripheralDisconnected\
                        userInfo:@{@"errorInfo":@"The current connection device is in disconnect"}];\
        block(error);\
    });\
}\

#define fitpolo701ParamsError(block)\
if(block){\
    fitpolo701_main_safe(^{\
        NSError *error = [[NSError alloc] initWithDomain:fitpolo701CustomErrorDomain\
                        code:fitpolo701ParamsError\
                        userInfo:@{@"errorInfo":@"input parameter error"}];\
        block(error);\
    });\
}\

#define fitpolo701CommunicationTimeout(block)\
if(block){\
    fitpolo701_main_safe(^{\
        NSError *error = [[NSError alloc] initWithDomain:fitpolo701CustomErrorDomain\
                        code:fitpolo701CommunicationTimeOut\
                        userInfo:@{@"errorInfo":@"Data communication timeout"}];\
        block(error);\
    });\
}\

#define fitpolo701RequestPeripheralDataError(block)\
if(block){\
    fitpolo701_main_safe(^{\
        NSError *error = [[NSError alloc] initWithDomain:fitpolo701CustomErrorDomain\
                        code:fitpolo701RequestPeripheralDataError\
                        userInfo:@{@"errorInfo":@"Request bracelet data error"}];\
        block(error);\
    });\
}\

#define fitpolo701BleStateError(block)\
if(block){\
    fitpolo701_main_safe(^{\
        NSError *error = [[NSError alloc] initWithDomain:fitpolo701CustomErrorDomain\
                        code:fitpolo701BlueDisable\
                        userInfo:@{@"errorInfo":@"mobile phone bluetooth is currently unavailable"}];\
        block(error);\
    });\
}\

#define fitpolo701CharacteristicError(block)\
if(block){\
    fitpolo701_main_safe(^{\
        NSError *error = [[NSError alloc] initWithDomain:fitpolo701CustomErrorDomain\
                        code:fitpolo701CharacteristicError\
                        userInfo:@{@"errorInfo":@"characteristic error"}];\
    block(error);\
    });\
}\

/**
 数据通信成功
 
 @param returnData 返回的Json数据
 */
typedef void(^fitpolo701CommunicationSuccessBlock)(id returnData);

/**
 数据通信失败
 
 @param error 失败原因
 */
typedef void(^fitpolo701CommunicationFailedBlock)(NSError *error);

/**
 监测当前中心和外设连接状态
 
 @param status 连接状态
 */
typedef void(^fitpolo701ConnectStatusChangedBlock)(fitpolo701ConnectStatus status);

/**
 监测当前中心的蓝牙状态
 
 @param status 蓝牙状态
 */
typedef void(^fitpolo701CentralStatusChangedBlock)(fitpolo701CentralManagerState status);

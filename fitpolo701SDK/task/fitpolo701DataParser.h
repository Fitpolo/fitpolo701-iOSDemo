//
//  fitpolo701DataParser.h
//  testSDK
//
//  Created by aa on 2018/3/15.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "fitpolo701TaskIDDefines.h"

extern NSString *const fitpolo701CommunicationDataNum;

@interface fitpolo701ParseResultModel : NSObject

@property (nonatomic, assign)fitpolo701TaskOperationID operationID;

@property (nonatomic, strong)id returnData;

@end

@interface fitpolo701DataParser : NSObject

@property (nonatomic, strong)NSMutableArray *dataList;

- (void)parseReadData:(NSString *)readData;

@end

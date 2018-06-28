//
//  fitpolo701OperationManager.h
//  testSDK
//
//  Created by aa on 2018/3/15.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "fitpolo701TaskOperation.h"

@interface fitpolo701OperationManager : NSObject

/**
 添加任务到队列
 
 @param operation operation
 */
- (void)addOperation:(fitpolo701TaskOperation *)operation;

/**
 取消所有任务
 */
- (void)cancelAllOperations;

@end

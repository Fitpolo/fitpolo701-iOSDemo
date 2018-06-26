//
//  fitpolo701OperationManager.m
//  testSDK
//
//  Created by aa on 2018/3/15.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo701OperationManager.h"

@interface fitpolo701OperationManager()

@property (nonatomic, strong)NSOperationQueue *operationQueue;

@end

@implementation fitpolo701OperationManager

- (void)dealloc{
    NSLog(@"队列销毁");
}

#pragma mark - Public method
/**
 添加任务到队列
 
 @param operation operation
 */
- (void)addOperation:(fitpolo701TaskOperation *)operation{
    if (!operation) {
        return;
    }
    [self.operationQueue addOperation:operation];
}

/**
 取消所有任务
 */
- (void)cancelAllOperations{
    [self.operationQueue cancelAllOperations];
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

//
//  fitpolo701DataParser.h
//  testSDK
//
//  Created by aa on 2018/3/15.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const fitpolo701CommunicationDataNum;

@interface fitpolo701DataParser : NSObject

+ (NSDictionary *)parseReadData:(NSString *)readData;

@end

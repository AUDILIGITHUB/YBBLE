//
//  YBBLE.h
//  YBBLE
//
//  Created by LPC on 2018/2/5.
//  Copyright © 2018年 audi. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface YBBLE : NSObject

typedef NS_ENUM(NSInteger,YBBLEChannel){//频道
    YBBLEChannel_openBLELock = 0//开锁
};

///当前频道
@property (nonatomic ,assign,readonly)YBBLEChannel channel;

///构造方法
+ (instancetype)ble;

/**
 开锁
 @param lockName 开锁名称
 @param openLockMsg 开锁报文
 @param timeOutValue 超时时间
 */
- (void)yb_openBLELock:(NSString *)lockName
           openLockMsg:(NSString *)openLockMsg
          timeOutValue:(NSTimeInterval)timeOutValue;

@end

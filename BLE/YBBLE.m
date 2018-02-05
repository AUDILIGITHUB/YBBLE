//
//  YBBLE.m
//  YBBLE
//
//  Created by LPC on 2018/2/5.
//  Copyright © 2018年 audi. All rights reserved.
//  LPC
// https://www.cnblogs.com/gaozhang12345/p/5856728.html翻译

#import "YBBLE.h"
#import <CoreBluetooth/CoreBluetooth.h>
/**蓝牙UUID*/
NSString *const YBBLE_SERVICE_UUID = @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
NSString *const YBBLE_CHARACTER_WRITE_UUID = @"6E400002-B5A3-F393-E0A9-E50E24DCCA9E";
NSString *const YBBLE_CHARACTER_READ_UUID = @"6E400003-B5A3-F393-E0A9-E50E24DCCA9E";

@interface YBBLE()<CBCentralManagerDelegate>
{
    __strong CBCentralManager *centralManager;
    __weak NSString *_lockName;
    __weak NSString *_openLockMsg;
    ///借车超时时长
    NSTimer *_openLockTimer;
}

@end
@implementation YBBLE

static YBBLE* _instance = nil;

+ (instancetype)ble{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL]init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    return [self ble];
}

- (instancetype)init{
    if (self = [super init]) {
        centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey:@NO}];
    }
    return self;
}

- (void)reset{
    self->_lockName = nil;
    self->_openLockMsg = nil;
    if (self->_openLockTimer) {
        [self->_openLockTimer invalidate];
        self->_openLockTimer = nil;
    }
}

#pragma mark - public
- (void)yb_openBLELock:(NSString *)lockName openLockMsg:(NSString *)openLockMsg timeOutValue:(NSTimeInterval)timeOutValue{
    [self reset];
    _lockName = lockName;
    _openLockMsg = openLockMsg;
    _channel = YBBLEChannel_openBLELock;
    self->_openLockTimer = [NSTimer timerWithTimeInterval:timeOutValue target:self selector:@selector(timeOut:) userInfo:nil repeats:NO];
    NSArray *servicesUUID = @[[CBUUID UUIDWithString:YBBLE_SERVICE_UUID]];
    [centralManager scanForPeripheralsWithServices:servicesUUID options:nil];
}

#pragma mark - action
- (void)timeOut:(id)sender{
    //开锁超时
    if (sender == self->_openLockTimer) {
        [self->_openLockTimer invalidate];
        self->_openLockTimer = nil;
    }
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    NSLog(@"状态更新");
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    NSString *lockName = advertisementData[@"kCBAdvDataLocalName"];
    if (![lockName isEqualToString:self->_lockName]) {
        return;
    }
    
    switch (_channel) {
        case YBBLEChannel_openBLELock:
            [central connectPeripheral:peripheral options:nil];
            break;
            
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    
}



@end

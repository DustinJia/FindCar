//
//  Reachability.h
//  CarFinder
//
//  Created by Dustin on 15-2-7.
//  Copyright (c) 2015年 Dustin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

typedef enum : NSInteger {
    NotReachable = 0,
    ReachableViaWiFi,
    ReachableViaWWAN
} NetworkStatus;

@interface Reachability : NSObject

+ (instancetype)reachabilityForInternetConnection;
+ (instancetype)reachabilityForLocalWiFi;

- (NetworkStatus)currentReachabilityStatus;

@end

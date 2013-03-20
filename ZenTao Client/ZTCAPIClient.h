//
//  ZTCAPIClient.h
//  ZenTao Client
//
//  Created by Puttin Wong on 3/19/13.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFHTTPClient.h"

@interface ZTCAPIClient : AFHTTPClient

+ (ZTCAPIClient *)sharedClient;
+ (void) login;
+ (NSMutableDictionary *) dealWithZTStrangeJSON:(id)JSON;

@end

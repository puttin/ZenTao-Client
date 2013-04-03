//
//  ZTCAPIClient.h
//  ZenTao Client
//
//  Created by Puttin Wong on 3/19/13.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFHTTPClient.h"

enum {
	GETIndex = 0,
    PATHINFOIndex = 1,
} RequestTypeIndicies;

@interface ZTCAPIClient : AFHTTPClient

+ (ZTCAPIClient *)sharedClient;
+ (BOOL) loginWithAccount:(NSString *)account Password:(NSString *)password Mode:(NSUInteger)mode BaseURL:(NSString *)url;
+ (NSMutableDictionary *) dealWithZTStrangeJSON:(id)JSON;
+ (void) registerUserInfo;
+ (NSUInteger) getRequestType;
+ (NSString*) getUrlWithType:(NSUInteger)type, ...;
+ (NSString*) getUrlWithType:(NSUInteger)type withParameters:(va_list)valist;
@end

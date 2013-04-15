//
//  ZTCAPIClient.h
//  ZenTao Client
//
//  Created by Puttin Wong on 3/19/13.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFHTTPClient.h"

#define kZTCKeychainAccount  @"ZTCAccount"
#define kZTCKeychainPassword @"ZTCPassword"
#define kZTCKeychainUrl      @"ZTCUrl"
enum {
	GETIndex = 0,
    PATHINFOIndex = 1,
    ERRORIndex = 100,
} RequestTypeIndicies;

@interface ZTCAPIClient : AFHTTPClient

+ (ZTCAPIClient *)sharedClient;
+ (BOOL) loginWithAccount:(NSString *)account Password:(NSString *)password BaseURL:(NSString *)url;
+ (NSMutableDictionary *) dealWithZTStrangeJSON:(id)JSON;
+ (void) registerUserInfo;
+ (NSUInteger) getRequestType;
+ (NSString*) getUrlWithType:(NSUInteger)type, ...;
+ (NSString*) getUrlWithType:(NSUInteger)type withParameters:(va_list)valist;
@end

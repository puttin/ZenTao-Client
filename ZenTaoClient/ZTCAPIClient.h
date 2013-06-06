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

typedef NS_ENUM(NSUInteger, RequestType) {
	RequestTypeGET = 0,
    RequestTypePATHINFO = 1,
    RequestTypeERROR = 100,
};

@interface ZTCAPIClient : AFHTTPClient

+ (ZTCAPIClient *)sharedClient;

+ (void) registerUserInfo;
+ (RequestType) getRequestType;
+ (BOOL) loginWithAccount:(NSString *)account Password:(NSString *)password BaseURL:(NSString *)url;
+ (BOOL) logout;
+ (void) showMainView;
+ (UIView*)showLoginView:(BOOL)animated;

+ (NSString*) getUrlWithType:(RequestType)type withParameters:(NSArray *)parameters;

+ (NSMutableDictionary *) dealWithZTStrangeJSON:(id)JSON;
@end

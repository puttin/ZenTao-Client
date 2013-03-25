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
	GETIndex,
    PATHINFOIndex,
} RequestTypeIndicies;

@interface ZTCAPIClient : AFHTTPClient

+ (ZTCAPIClient *)sharedClient;
+ (BOOL) loginWithAccount:(NSString *)account Password:(NSString *)password Mode:(NSString *)mode BaseURL:(NSString *)url;
+ (NSMutableDictionary *) dealWithZTStrangeJSON:(id)JSON;
+ (void) registerUserInfo;
+ (NSString*) getUrlWithType:(NSUInteger)type, ...;
@end

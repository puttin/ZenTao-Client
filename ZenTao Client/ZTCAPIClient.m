//
//  ZTCAPIClient.m
//  ZenTao Client
//
//  Created by Puttin Wong on 3/19/13.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//

#import "ZTCAPIClient.h"

#import "AFJSONRequestOperation.h"
#import <CommonCrypto/CommonDigest.h>

static NSString * const kAPIBaseURLString = @"http://demo.zentao.net";
static NSString * const kCookieURLString = @"demo.zentao.net";
@implementation ZTCAPIClient

+ (ZTCAPIClient *)sharedClient {
    static ZTCAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[ZTCAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kAPIBaseURLString]];
    });
    
    return _sharedClient;
}

+ (void) login {
    
    ZTCAPIClient* api = [ZTCAPIClient sharedClient];
    
    //Get session
    [api getPath:@"api-getsessionid.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSMutableDictionary *dict = [self dealWithZTStrangeJSON:JSON];
        if ([dict count]) {
            DLog(@"%@:%@", [[dict objectForKey:@"data"] objectForKey:@"sessionName"],[[dict objectForKey:@"data"] objectForKey:@"sessionID"]);
            
            //[self clearCookieForURL:[NSURL URLWithString:kCookieURLString]];
            //[self addCookieWithName:[[dict objectForKey:@"data"] objectForKey:@"sessionName"]
            //              WithValue:[[dict objectForKey:@"data"] objectForKey:@"sessionID"]
            //                ForURL:kCookieURLString];
            
            //[self showAllCookie];
            
            //DLog(@"%@",dict);
        } else {
            NSLog(@"ERROR: Get no session!");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@",error);
    }];
    [api.operationQueue waitUntilAllOperationsAreFinished];
    
    //Login
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"demo", @"account",
                            @"123456", @"password",
                            nil];
    [api postPath:@"user-login.html" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //[self showAllCookie];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@",error);
    }];
    [api.operationQueue waitUntilAllOperationsAreFinished];
    
}

//ZenTao PMS always return a JSON with escape-character
//This method can remove the superfluous characters.
+ (NSMutableDictionary *) dealWithZTStrangeJSON:(id)JSON {
    NSMutableDictionary *dict = [NSDictionary dictionary];
    if (JSON) {
        dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:nil];
        if ([[dict objectForKey:@"status"] isEqualToString:@"success"]) {
            NSData *nestedJsonData = [[dict objectForKey:@"data"] dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *nestedDict = [NSJSONSerialization JSONObjectWithData:nestedJsonData options:NSJSONReadingMutableContainers error:nil];
            [dict setObject:nestedDict forKey:@"data"];
        } else {
            NSLog(@"Called failed or transfered not complete!");
        }
    }
    return dict;
}

+ (NSString *)md5HexDigest:(NSString*)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];//
    
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

+ (void) addCookieWithName:(id) name WithValue:(id) value ForURL:(NSString *) url {
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:name forKey:NSHTTPCookieName];
    [cookieProperties setObject:value forKey:NSHTTPCookieValue];
    [cookieProperties setObject:url forKey:NSHTTPCookieDomain];
    //[cookieProperties setObject:url forKey:NSHTTPCookieOriginURL];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:2629743] forKey:NSHTTPCookieExpires];
    [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    
    //DLog(@"%@", cookie);
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:[NSArray arrayWithObject:cookie] forURL:[NSURL URLWithString:url] mainDocumentURL:nil];
}

+ (void) showAllCookie {
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        DLog(@"%@", cookie);
    }
}

+ (void) clearCookieForURL:(NSURL *)url {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL: url];
    for (NSHTTPCookie *cookie in cookies)
    {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFURLConnectionOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	//[self setDefaultHeader:@"Accept" value:@"text/html"];
    
    return self;
}
@end

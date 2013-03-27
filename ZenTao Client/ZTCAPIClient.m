//
//  ZTCAPIClient.m
//  ZenTao Client
//
//  Created by Puttin Wong on 3/19/13.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>

#import "AFURLConnectionOperation.h"

#import "ZTCAPIClient.h"
#import "ZTCUserSettingsViewController.h"
#import "ZTCTaskListViewController.h"
#import "ZTCNotice.h"

#define TEST_MODE 0
static NSString * const kDemoAPIBaseURLString = @"http://demo.zentao.net";
static NSString * const kCookieURLString = @"demo.zentao.net";
static BOOL urlChanged = NO;
static NSUInteger requestType = 0;
static NSString * tmpUrl = nil;
@implementation ZTCAPIClient{
}

+ (ZTCAPIClient *)sharedClient {
    static ZTCAPIClient *_sharedClient = nil;
    if (TEST_MODE) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _sharedClient = [[ZTCAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kDemoAPIBaseURLString]];
        });
        return _sharedClient;
    } else {
        if (!tmpUrl) {
            return nil;
        }
        if (urlChanged) {
            NSURL *myURL;
            if ([tmpUrl hasPrefix:@"http://"]) {
                myURL = [NSURL URLWithString:tmpUrl];
            } else {
                myURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@",tmpUrl]];
            }
            _sharedClient = [[ZTCAPIClient alloc] initWithBaseURL:myURL];
            urlChanged = NO;
        }
        return _sharedClient;
    }
}
+ (void) makeRequestTo:(NSString *) urlStr
            parameters:(NSDictionary *) params
                method:(NSString *) method
       successCallback:(void (^)(id jsonResponse)) successCallback
         errorCallback:(void (^)(NSError * error, NSString *errorMsg)) errorCallback {
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    ZTCAPIClient *httpClient = [ZTCAPIClient sharedClient];
    
    httpClient.parameterEncoding = AFFormURLParameterEncoding;
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:method path:urlStr parameters:params];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if(error) {
        errorCallback(error, nil);
    } else {
        successCallback(data);
    }
}

+ (void)registerDefaultsFromSettingsBundle {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"ERROR: Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] init];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            if (![defaults objectForKey:key]) {//only when don't have this key
                [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
            }
            
        }
    }
    [defaults registerDefaults:defaultsToRegister];
}

+ (NSUInteger) getRequestType {
    return requestType?PATHINFOIndex:GETIndex;
}

+ (NSString*) getUrlWithType:(NSUInteger)type, ... {
    id eachObject;
    va_list argumentList;
    switch (type) {
        case GETIndex:
        {
            NSMutableString *str = [NSMutableString stringWithString:@"?"];
            va_start(argumentList, type);
            while ((eachObject = va_arg(argumentList, id))){
                [str appendString:@"&"];
                [str appendString:(NSString *)eachObject];
            }
            va_end(argumentList);
            [str appendString:@"&t=json"];
            [str deleteCharactersInRange:NSMakeRange(1, 1)];
            return str;
        }
            break;
            
        case PATHINFOIndex:
        {
            NSMutableString *str = [[NSMutableString alloc] init];
            va_start(argumentList, type);
            while ((eachObject = va_arg(argumentList, id))){
                [str appendString:@"-"];
                //[str appendString:(NSString *)eachObject];
                NSUInteger location = [((NSString *)eachObject) rangeOfString:@"="].location;
                [str appendString:[((NSString *)eachObject) substringFromIndex:location+1]];
                //DLog(@"location:%u",location);
            }
            va_end(argumentList);
            [str appendString:@".json"];
            [str deleteCharactersInRange:NSMakeRange(0, 1)];
            return str;
        }
            break;
        default:
            break;
    }
    return nil;
}

+ (void) registerUserInfo {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *account = [defaults stringForKey:@"account"];
    if(!account) {
        // load default value
        [self performSelector:@selector(registerDefaultsFromSettingsBundle)];
        ZTCUserSettingsViewController *userSettingsView = [[ZTCUserSettingsViewController alloc] init];
        UINavigationController *usersSettingsNav = [[UINavigationController alloc] initWithRootViewController:userSettingsView];
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentModalViewController:usersSettingsNav animated:NO];
        [ZTCNotice showSuccessNoticeInView:userSettingsView.view title:[NSString stringWithFormat:@"%@,%@",NSLocalizedString(@"login first time use title", nil),NSLocalizedString(@"login first time use message", nil)]];
    } else {
        if ([ZTCAPIClient loginWithAccount:[defaults stringForKey:@"account"] Password:[defaults stringForKey:@"password"] Mode:[defaults stringForKey:@"requestType"] BaseURL:[defaults stringForKey:@"url"]]) {
            //DLog(@"Log in SUCCESS");
            UITableViewController *viewController = [[ZTCTaskListViewController alloc] initWithStyle:UITableViewStylePlain];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
            [[[[UIApplication sharedApplication] delegate] window] setRootViewController:nav];
        } else {
            //DLog(@"Log in FAIL");
            ZTCUserSettingsViewController *userSettingsView = [[ZTCUserSettingsViewController alloc] init];
            UINavigationController *usersSettingsNav = [[UINavigationController alloc] initWithRootViewController:userSettingsView];
            [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentModalViewController:usersSettingsNav animated:NO];
            [ZTCNotice showErrorNoticeInView:userSettingsView.view title:NSLocalizedString(@"login fail title", nil) message:NSLocalizedString(@"login fail message", nil)];
        }
    }
    /*
    DLog(@"%@",[defaults stringForKey:@"account"]);
    DLog(@"%@",[defaults stringForKey:@"password"]);
    DLog(@"%@",[defaults stringForKey:@"url"]);
    DLog(@"%@",[defaults stringForKey:@"requestType"]);
    */
}

+ (BOOL) loginWithAccount:(NSString *)account
                 Password:(NSString *)password
                     Mode:(NSString *)mode
                  BaseURL:(NSString *)url {
    tmpUrl = url;
    urlChanged = YES;
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"]];
    NSUInteger tmpRequestType = [mode isEqualToString:NSLocalizedStringFromTableInBundle(@"RequestType PATH_INFO", @"Root", bundle, nil)]?PATHINFOIndex:GETIndex;
    __block BOOL sessionSuccess = NO;
    __block BOOL loginSuccess = NO;
    [ZTCAPIClient makeRequestTo:[ZTCAPIClient getUrlWithType:tmpRequestType,@"m=api",@"f=getsessionid",nil] parameters:nil method:@"GET" successCallback:^(id JSON){
        //DLog(@"JSON:%@",JSON);
        NSMutableDictionary *dict = [self dealWithZTStrangeJSON:JSON];
        //DLog(@"%@",dict);
        if ([dict count]) {
            //DLog(@"%@:%@", [[dict objectForKey:@"data"] objectForKey:@"sessionName"],[[dict objectForKey:@"data"] objectForKey:@"sessionID"]);
            sessionSuccess = YES;
        } else {
            NSLog(@"ERROR: Get no session!");
            sessionSuccess = NO;
        }
    } errorCallback:^(NSError *error, NSString *errorMsg) {
        NSLog(@"ERROR: Get session error:%@",error);
        sessionSuccess = NO;
    }];
    //DLog(@"login mid code %u",sessionSuccess);
    if (sessionSuccess) {
        //Login
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                account, @"account",
                                password, @"password",
                                nil];
        [ZTCAPIClient makeRequestTo:[ZTCAPIClient getUrlWithType:tmpRequestType,@"m=user",@"f=login",nil] parameters:params method:@"POST" successCallback:^(id JSON) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:nil];
            if ([[dict objectForKey:@"status"] isEqualToString:@"success"]) {
                loginSuccess = YES;
            } else {
                loginSuccess = NO;
            }
        } errorCallback:^(NSError *error, NSString *errorMsg) {
            NSLog(@"ERROR: Log in error:%@",error);
            loginSuccess = NO;
        }];
    } else {
        loginSuccess = NO;
    }
    //DLog(@"login last code %u",loginSuccess);
    if (loginSuccess) {
        requestType = tmpRequestType;
    }
    return loginSuccess;
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

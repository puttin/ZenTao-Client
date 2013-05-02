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
#import "ZTCListViewController.h"
#import "ZTCNotice.h"
#import "PDKeychainBindings.h"
//sideMenu
#import "IIViewDeckController.h"
#import "ZTCMenuViewController.h"

#define TEST_MODE 0
#define kHasKeychain          @"Keychain"
#define kDemoAPIBaseURLString @"http://demo.zentao.net"
#define kCookieURLString      @"demo.zentao.net";
static BOOL urlChanged = NO;
static NSUInteger requestType = ERRORIndex;
static NSString * tmpUrl = nil;

@implementation ZTCAPIClient {
    
}

#pragma mark -

+ (ZTCAPIClient *)sharedClient {
    static ZTCAPIClient *_sharedClient = nil;
    if (TEST_MODE) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _sharedClient = [[ZTCAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kDemoAPIBaseURLString]];
            [_sharedClient setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
                if (status == AFNetworkReachabilityStatusNotReachable) {
                    // Not reachable
                    [ZTCNotice showErrorNoticeInView:[((UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController]) visibleViewController].view title:NSLocalizedString(@"network not reachable title", nil) message:NSLocalizedString(@"network not reachable message", nil)];
                } else {
                    // Reachable
                }
            }];
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
            //DLog(@"%@",myURL);
            _sharedClient = [[ZTCAPIClient alloc] initWithBaseURL:myURL];
            [_sharedClient setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
                if (status == AFNetworkReachabilityStatusNotReachable) {
                    // Not reachable
                    [ZTCNotice showErrorNoticeInView:[((UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController]) visibleViewController].view title:NSLocalizedString(@"network not reachable title", nil) message:NSLocalizedString(@"network not reachable message", nil)];
                } else {
                    // Reachable
                }
            }];
            urlChanged = NO;
        }
        return _sharedClient;
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

+ (void) makeRequestTo:(NSString *) urlStr
            parameters:(NSDictionary *) params
                method:(NSString *) method
       successCallback:(void (^)(id jsonResponse)) successCallback
         errorCallback:(void (^)(NSError * error, NSString *errorMsg)) errorCallback {
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:method];
    if (params) {
        if ([method isEqualToString:@"GET"] || [method isEqualToString:@"HEAD"] || [method isEqualToString:@"DELETE"]) {
            url = [NSURL URLWithString:[[url absoluteString] stringByAppendingFormat:[urlStr rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@", AFQueryStringFromParametersWithEncoding(params, NSUTF8StringEncoding)]];
            [request setURL:url];
        }
    }
    //DLog(@"%@",url);
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if(error) {
        errorCallback(error, nil);
    } else {
        successCallback(data);
    }
}

+ (NSUInteger) getRequestType {
    return requestType?PATHINFOIndex:GETIndex;
}

+ (NSString*) getUrlWithType:(NSUInteger)type withParameters:(NSArray *)parameters  {
    switch (type) {
        case GETIndex:
        {
            NSMutableString *str = [NSMutableString stringWithString:@"index.php?"];
            [parameters enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [str appendString:@"&"];
                [str appendString:(NSString *)obj];
            }];
            [str appendString:@"&t=json"];
            [str deleteCharactersInRange:NSMakeRange(10, 1)];
            return str;
        }
            break;
            
        case PATHINFOIndex:
        {
            NSMutableString *str = [[NSMutableString alloc] init];
            [parameters enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [str appendString:@"-"];
                //[str appendString:(NSString *)eachObject];
                NSUInteger location = [((NSString *)obj) rangeOfString:@"="].location;
                [str appendString:[((NSString *)obj) substringFromIndex:location+1]];
                //DLog(@"location:%u",location);
            }];
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

#pragma mark - Register and login

+ (void)registerDefaultsFromPlist:(NSString*)plistName {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *settingsPlistPath = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    if(!settingsPlistPath) {
        NSLog(@"ERROR: Could not find %@.plist",plistName);
        return;
    }
    
    NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:settingsPlistPath];
    
    [defaults registerDefaults:settings];
}

+ (void) registerUserInfo {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PDKeychainBindings *bindings = [PDKeychainBindings sharedKeychainBindings];
        NSString *account = [bindings objectForKey:kZTCKeychainAccount];
        NSString *password = [bindings objectForKey:kZTCKeychainPassword];
        NSString *url = [bindings objectForKey:kZTCKeychainUrl];
        //DLog(@"\n*************\naccount:%@\npassword:%@\nurl:%@\n*************",account,password,url);
        if( !account || !password || !url ) {
            // load default value
            [self registerDefaultsFromPlist:@"demo"];
            dispatch_async(dispatch_get_main_queue(), ^{
                ZTCUserSettingsViewController *userSettingsView = [[ZTCUserSettingsViewController alloc] init];
                UINavigationController *usersSettingsNav = [[UINavigationController alloc] initWithRootViewController:userSettingsView];
                [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentModalViewController:usersSettingsNav animated:NO];
                [ZTCNotice showSuccessNoticeInView:userSettingsView.view title:[NSString stringWithFormat:@"%@,%@",NSLocalizedString(@"login first time use title", nil),NSLocalizedString(@"login first time use message", nil)]];//TODO
            });
        } else {
            if ([ZTCAPIClient loginWithAccount:account Password:password BaseURL:url]) {
                //DLog(@"Log in SUCCESS");
                [self showMainView];
            } else {
                //DLog(@"Log in FAIL");
                [[NSUserDefaults standardUserDefaults] registerDefaults:@{
                 @"account": account,//same key with demo.plist
                 @"password": password,
                 @"url": url
                 }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    ZTCUserSettingsViewController *userSettingsView = [[ZTCUserSettingsViewController alloc] init];
                    UINavigationController *usersSettingsNav = [[UINavigationController alloc] initWithRootViewController:userSettingsView];
                    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentModalViewController:usersSettingsNav animated:NO];
                    [ZTCNotice showErrorNoticeInView:userSettingsView.view title:NSLocalizedString(@"login fail title", nil) message:NSLocalizedString(@"login fail message", nil)];
                });
            }
        }
    });
}

+ (NSUInteger) getRequestTypeOfWebsite:(NSString *)url {
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"]];
    __block NSUInteger type = ERRORIndex;
    NSString *configURL = [NSString stringWithFormat:@"%@index.php?mode=getconfig",url];
    //DLog(@"%@",configURL);
    [ZTCAPIClient makeRequestTo:configURL parameters:nil method:@"GET" successCallback:^(id JSON){
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:nil];
        //DLog(@"%@",dict);
        NSString *requestType = [dict objectForKey:@"requestType"];
        if (requestType) {
            type = [requestType isEqualToString:NSLocalizedStringFromTableInBundle(@"RequestType PATH_INFO", @"Root", bundle, nil)]?PATHINFOIndex:GETIndex;
        }
    } errorCallback:^(NSError *error, NSString *errorMsg) {
        NSLog(@"ERROR: Get request type error:%@",error);
    }];
    //DLog(@"%u",type);
    return type;
}

+ (BOOL) loginWithAccount:(NSString *)account
                 Password:(NSString *)password
                  BaseURL:(NSString *)url {
    if (![url hasSuffix:@"/"]) {
        url = [NSString stringWithFormat:@"%@/",url];
    }
    if (![url hasPrefix:@"http://"]) {
        url = [NSString stringWithFormat:@"http://%@",url];
    }
    NSUInteger tmpRequestType = [ZTCAPIClient getRequestTypeOfWebsite:url];
    if (tmpRequestType == ERRORIndex) {
        return NO;
    }
    __block BOOL sessionSuccess = NO;
    __block BOOL loginSuccess = NO;
    [ZTCAPIClient makeRequestTo:[NSString stringWithFormat:@"%@%@",url,[ZTCAPIClient getUrlWithType:tmpRequestType withParameters:@[@"m=api",@"f=getsessionid"]]] parameters:nil method:@"GET" successCallback:^(id JSON){
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
        [ZTCAPIClient makeRequestTo:[NSString stringWithFormat:@"%@%@",url,[ZTCAPIClient getUrlWithType:tmpRequestType withParameters:@[@"m=user",@"f=login"]]] parameters:params method:@"GET" successCallback:^(id JSON) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:nil];
            //DLog(@"%@",dict);
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
    tmpUrl = url;
    urlChanged = YES;
    return loginSuccess;
}

+ (void) showMainView {
    DLog(@"showMainView");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self registerDefaultsFromPlist:@"moduleAndMethod"];
        dispatch_async(dispatch_get_main_queue(), ^{
            //center
            UIViewController *viewController = [[ZTCListViewController alloc] init];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
            //mainMenu
            UIViewController *mainMenu = [[ZTCMenuViewController alloc] initWithType:MenuTypeMainMenu];
//            UINavigationController *mainMenuNav = [[UINavigationController alloc] initWithRootViewController:mainMenu];
            //subMenu
            UIViewController *subMenu = [[ZTCMenuViewController alloc] initWithType:MenuTypeSubMenu];
//            UINavigationController *subMenuNav = [[UINavigationController alloc] initWithRootViewController:subMenu];
            
            IIViewDeckController* menuDeckController =  [[IIViewDeckController alloc] initWithCenterViewController:subMenu
                                                                                                leftViewController:mainMenu];
            if (IS_IPAD) {
                menuDeckController.leftSize = 600;
            } else {
                menuDeckController.leftSize = 160;
            }
            menuDeckController.delegateMode = IIViewDeckDelegateAndSubControllers;
            menuDeckController.panningMode = IIViewDeckNoPanning;
            menuDeckController.sizeMode = IIViewDeckViewSizeMode;
            
            IIViewDeckController* deckController =  [[IIViewDeckController alloc] initWithCenterViewController:nav
                                                                                            leftViewController:menuDeckController];
            if (IS_IPAD) {
                deckController.leftSize = 500;
            } else {
                deckController.leftSize = 44;
            }
            deckController.delegateMode = IIViewDeckDelegateAndSubControllers;
            deckController.panningMode = IIViewDeckNavigationBarOrOpenCenterPanning;
            deckController.sizeMode = IIViewDeckViewSizeMode;
            deckController.bounceDurationFactor = 0.7;
            
            [[[[UIApplication sharedApplication] delegate] window] setRootViewController:deckController];
        });
    });
}

#pragma mark -

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

#pragma mark - md5 (no use now)

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

#pragma mark - Cookie (no use now)

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

@end

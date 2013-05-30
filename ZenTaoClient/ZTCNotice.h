//
//  ZTCNotice.h
//  ZenTao Client
//
//  Created by Puttin Wong on 3/27/13.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZTCNotice : NSObject

+ (void) showErrorNoticeInView:(UIView *)view title:(NSString *)title message:(NSString *)message;
+ (void)showSuccessNoticeInView:(UIView *)view title:(NSString *)title;

@end

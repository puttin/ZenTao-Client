//
//  ZTCNotice.m
//  ZenTao Client
//
//  Created by Puttin Wong on 3/27/13.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//

#import "ZTCNotice.h"
#import "WBNoticeView.h"
#import "WBErrorNoticeView.h"
#import "WBSuccessNoticeView.h"

@implementation ZTCNotice


+ (void) showErrorNoticeInView:(UIView *)view title:(NSString *)title message:(NSString *)message
{
    WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInView:view title:title message:message];
    [notice show];
}

+ (void)showSuccessNoticeInView:(UIView *)view title:(NSString *)title
{
    WBSuccessNoticeView *notice = [WBSuccessNoticeView successNoticeInView:view title:title];
    [notice show];
}

@end

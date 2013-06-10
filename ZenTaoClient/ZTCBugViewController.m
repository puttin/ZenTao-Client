//
//  ZTCBugViewController.m
//  ZenTao Client
//
//  Created by Puttin Wong on 04/21/2013.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//

#import <QuickDialog/QuickDialog.h>
#import "ZTCBugViewController.h"
#import "ZTCAPIClient.h"
#import "ZTCNotice.h"

@interface ZTCBugViewController ()
@property (assign, nonatomic) NSUInteger bugID;
@property (strong, nonatomic) NSDictionary *valueDict;
@end

@implementation ZTCBugViewController

- (id)initWithID:(id) ID
{
    self = [super init];
    if (self) {
        // Custom initialization
        _bugID = [ID intValue];
        self.root = [[QRootElement alloc] initWithJSONFile:@"bugDetail"];
        self.root.title = NSLocalizedString(@"Loading...", @"tell user it's loading data");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.quickDialogTableView.deselectRowWhenViewAppears = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    ZTCAPIClient* api = [ZTCAPIClient sharedClient];
    NSString *bugPath = [ZTCAPIClient getUrlWithType:[ZTCAPIClient getRequestType] withParameters:@[@"m=bug",@"f=view",[NSString stringWithFormat:@"id=%u",self.bugID]]];
    [api getPath:bugPath parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableDictionary *dict = [ZTCAPIClient dealWithZTStrangeJSON:JSON];
            NSDictionary *productsDict = dict[@"data"][@"products"];
            NSDictionary *bugDict = dict[@"data"][@"bug"];
            NSDictionary *usersDict = dict[@"data"][@"users"];
            self.valueDict = @{
                               @"title": bugDict[@"title"],
                               @"steps": bugDict[@"steps"],
                               //basic
                               @"product": productsDict[bugDict[@"product"]],
                               @"module": bugDict[@"module"],
                               @"type": [[NSBundle mainBundle] localizedStringForKey:([NSString stringWithFormat:@"bug type %@",bugDict[@"type"]]) value:@"" table:nil],
                               @"severity": [[NSBundle mainBundle] localizedStringForKey:([NSString stringWithFormat:@"bug severity %@",bugDict[@"severity"]]) value:@"" table:nil],
                               @"pri": [[NSBundle mainBundle] localizedStringForKey:([NSString stringWithFormat:@"bug pri %@",bugDict[@"pri"]]) value:@"" table:nil],
                               @"status": [[NSBundle mainBundle] localizedStringForKey:([NSString stringWithFormat:@"bug status %@",bugDict[@"status"]]) value:@"" table:nil],
                               @"activatedCount": bugDict[@"activatedCount"],
                               @"confirmed": [[NSBundle mainBundle] localizedStringForKey:([NSString stringWithFormat:@"bug confirmed %@",bugDict[@"confirmed"]]) value:@"" table:nil],
                               @"assignedTo": [NSString stringWithFormat:@"%@ %@ %@",usersDict[bugDict[@"assignedTo"]],NSLocalizedString(@"task at", nil),bugDict[@"assignedDate"]],
                               @"os": [[NSBundle mainBundle] localizedStringForKey:([NSString stringWithFormat:@"bug os %@",bugDict[@"os"]]) value:@"" table:nil],
                               @"browser": [[NSBundle mainBundle] localizedStringForKey:([NSString stringWithFormat:@"bug browser %@",bugDict[@"browser"]]) value:@"" table:nil],
                               @"keywords": bugDict[@"keywords"],
                               //case
                               @"caseTitle": bugDict[@"caseTitle"]?bugDict[@"caseTitle"]:@"",
                               @"toCases": ([bugDict[@"toCases"] count] == 1 ) ? bugDict[@"toCases"][[[bugDict[@"toCases"] allKeys] lastObject]] : ( ([bugDict[@"toCases"] count] == 0 ) ? @"" : [NSString stringWithFormat:@"%u %@",[bugDict[@"toCases"] count], [[NSBundle mainBundle] localizedStringForKey:@"bug toCase multi" value:@"" table:nil] ] ),
                               //lifetime
                               @"openedBy": [bugDict[@"openedDate"] isEqualToString:@""]?@"":[NSString stringWithFormat:@"%@ %@ %@",usersDict[bugDict[@"openedBy"]],NSLocalizedString(@"bug at", nil),bugDict[@"openedDate"]],
                               @"openedBuild": bugDict[@"openedBuild"],
                               @"resolvedBy": [bugDict[@"resolvedDate"] isEqualToString:@""]?@"":[NSString stringWithFormat:@"%@ %@ %@",usersDict[bugDict[@"resolvedBy"]],NSLocalizedString(@"bug at", nil),bugDict[@"resolvedDate"]],
                               @"resolvedBuild": bugDict[@"resolvedBuild"],
                               @"resolution": [NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] localizedStringForKey:([NSString stringWithFormat:@"bug resolution %@",bugDict[@"resolution"]]) value:@"" table:nil],bugDict[@"duplicateBugTitle"]?[NSString stringWithFormat:@" #%@ %@",bugDict[@"duplicateBug"],bugDict[@"duplicateBugTitle"]]:@""],
                               @"closedBy": [bugDict[@"closedDate"] isEqualToString:@""]?@"":[NSString stringWithFormat:@"%@ %@ %@",usersDict[bugDict[@"closedBy"]],NSLocalizedString(@"bug at", nil),bugDict[@"closedDate"]],
                               @"lastEditedBy": [bugDict[@"lastEditedDate"] isEqualToString:@""]?@"":[NSString stringWithFormat:@"%@ %@ %@",usersDict[bugDict[@"lastEditedBy"]],NSLocalizedString(@"bug at", nil),bugDict[@"lastEditedDate"]],
                               //Project, story & task
                               @"project": [bugDict[@"project"] intValue]?bugDict[@"projectName"]:@"",
                               @"story": [bugDict[@"story"] intValue]?bugDict[@"storyTitle"]:@"",
                               @"task": [bugDict[@"task"] intValue]?bugDict[@"taskName"]:@"",
                               //misc
                               @"mailto": bugDict[@"mailto"],
                               @"linkBug": ([bugDict[@"linkBugTitles"] count] == 1 ) ? bugDict[@"linkBugTitles"][[[bugDict[@"linkBugTitles"] allKeys] lastObject]] : ( ([bugDict[@"linkBugTitles"] count] == 0 ) ? @"" : [NSString stringWithFormat:@"%u %@",[bugDict[@"linkBugTitles"] count], [[NSBundle mainBundle] localizedStringForKey:@"bug linkBug multi" value:@"" table:nil] ] ),
                               @"case": bugDict[@"caseTitle"] ? bugDict[@"caseTitle"] : @"",
                               @"toStory": bugDict[@"toStoryTitle"] ? bugDict[@"toStoryTitle"] : @"",
                               @"toTask": bugDict[@"toTaskTitle"] ? bugDict[@"toTaskTitle"] : @"",
                               };
            
            //reload the view
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.root bindToObject:self.valueDict];
                self.title = [NSString stringWithFormat:@"%@ #%u",NSLocalizedString(@"bug", nil),self.bugID];
                [self.quickDialogTableView reloadData];
            });
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@",error);
        dispatch_sync(dispatch_get_main_queue(), ^{
            [ZTCNotice showErrorNoticeInView:self.view title:NSLocalizedString(@"error", nil) message:error.localizedDescription];
        });
    }];
}

#pragma mark - Rotate

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (IS_IPAD) {
        return YES;
    } else {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSInteger)supportedInterfaceOrientations{
    NSInteger mask = 0;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeRight])
        mask |= UIInterfaceOrientationMaskLandscapeRight;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeLeft])
        mask |= UIInterfaceOrientationMaskLandscapeLeft;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortrait])
        mask |= UIInterfaceOrientationMaskPortrait;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortraitUpsideDown])
        mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    return mask;
}

@end

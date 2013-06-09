//
//  ZTCTaskViewController.m
//  ZenTao Client
//
//  Created by Puttin Wong on 3/20/13.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//

#import <QuickDialog/QuickDialog.h>
#import "ZTCTaskViewController.h"
#import "ZTCAPIClient.h"
#import "ZTCNotice.h"

@interface ZTCTaskViewController ()
@property (assign, nonatomic) NSUInteger taskID;
@property (strong, nonatomic) NSDictionary *valueDict;
@end

@implementation ZTCTaskViewController

- (id)initWithID:(id) ID
{
    self = [super init];
    if (self) {
        // Custom initialization
        _taskID = [ID intValue];
        self.root = [[QRootElement alloc] initWithJSONFile:@"taskDetail"];
        self.root.title = NSLocalizedString(@"Loading...", @"tell user it's loading data");
    }
    return self;
}

- (void)viewDidLoad {
    self.quickDialogTableView.deselectRowWhenViewAppears = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    ZTCAPIClient* api = [ZTCAPIClient sharedClient];
    [api getPath:[ZTCAPIClient getUrlWithType:[ZTCAPIClient getRequestType] withParameters:@[@"m=task",@"f=view",[NSString stringWithFormat:@"id=%u",self.taskID]]] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableDictionary *dict = [ZTCAPIClient dealWithZTStrangeJSON:JSON];
            NSDictionary *projectDict = dict[@"data"][@"project"];
            NSDictionary *taskDict = dict[@"data"][@"task"];
            NSDictionary *usersDict = dict[@"data"][@"users"];
            self.valueDict = @{
                               @"name": taskDict[@"name"],
                               @"desc": taskDict[@"desc"],
                               //basic info
                               @"project": (projectDict)[@"name"],
                               @"module": taskDict[@"module"],
                               @"story": [taskDict[@"story"] intValue]?taskDict[@"storyTitle"]:@"",
                               @"assignedTo": [NSString stringWithFormat:@"%@ %@ %@",taskDict[@"assignedToRealName"],NSLocalizedString(@"task at", nil),taskDict[@"assignedDate"]],
                               @"type": [[NSBundle mainBundle] localizedStringForKey:([NSString stringWithFormat:@"task type %@",taskDict[@"type"]]) value:@"" table:nil],
                               @"status": [[NSBundle mainBundle] localizedStringForKey:([NSString stringWithFormat:@"task status %@",taskDict[@"status"]]) value:@"" table:nil],
                               @"pri": taskDict[@"pri"],
                               @"mailto": taskDict[@"mailto"],
                               //effort
                               @"estimateStart": taskDict[@"estStarted"],
                               @"realStarted": taskDict[@"realStarted"],
                               @"deadline": taskDict[@"deadline"],
                               @"estimate": [NSString stringWithFormat:@"%@ %@",taskDict[@"estimate"],NSLocalizedString(@"task hour", nil)],
                               @"consumed": [NSString stringWithFormat:@"%@ %@",taskDict[@"consumed"],NSLocalizedString(@"task hour", nil)],
                               @"left": [NSString stringWithFormat:@"%@ %@",taskDict[@"left"],NSLocalizedString(@"task hour", nil)],
                               //lifetime
                               @"opened": [taskDict[@"openedDate"] isEqualToString:@""]?@"":[NSString stringWithFormat:@"%@ %@ %@",usersDict[taskDict[@"openedBy"]],NSLocalizedString(@"task at", nil),taskDict[@"openedDate"]],
                               @"finished": [taskDict[@"finishedDate"] isEqualToString:@""]?@"":[NSString stringWithFormat:@"%@ %@ %@",usersDict[taskDict[@"finishedBy"]],NSLocalizedString(@"task at", nil),taskDict[@"finishedDate"]],
                               @"canceled": [taskDict[@"canceledDate"] isEqualToString:@""]?@"":[NSString stringWithFormat:@"%@ %@ %@",usersDict[taskDict[@"canceledBy"]],NSLocalizedString(@"task at", nil),taskDict[@"canceledDate"]],
                               @"closed": [taskDict[@"closedDate"] isEqualToString:@""]?@"":[NSString stringWithFormat:@"%@ %@ %@",usersDict[taskDict[@"closedBy"]],NSLocalizedString(@"task at", nil),taskDict[@"closedDate"]],
                               @"closedReason": taskDict[@"closedReason"],
                               @"edited": [taskDict[@"lastEditedDate"] isEqualToString:@""]?@"":[NSString stringWithFormat:@"%@ %@ %@",usersDict[taskDict[@"lastEditedBy"]],NSLocalizedString(@"task at", nil),taskDict[@"lastEditedDate"]]
                               };
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.root bindToObject:self.valueDict];
                self.title = [NSString stringWithFormat:@"%@ #%u",NSLocalizedString(@"task", nil),self.taskID];
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

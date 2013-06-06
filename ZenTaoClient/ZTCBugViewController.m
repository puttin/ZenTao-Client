//
//  ZTCBugViewController.m
//  ZenTao Client
//
//  Created by Puttin Wong on 04/21/2013.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//

#import "ZTCBugViewController.h"
#import "ZTCAPIClient.h"
#import "ZTCNotice.h"

#define SMALL_FONT_SIZE 15.0f
#define CELL_CONTENT_MARGIN 10.0f
#define CELL_CONTENT_DEFAULT_HEIGHT 44.0f
enum {
    BugSectionIndex = 0,
    BugBasicSectionIndex,
    BugCaseSectionIndex,
    BugLifetimeSectionIndex,
    BugPSTSectionIndex,
    BugMiscSectionIndex,
    SectionsCount,          //count
} BugSectionIndicies;

enum {
    BugStepsRowIndex = 0,
    InfoRowsCount,          //count
} BugInfoSectionRowIndicies;

enum {
    BugProductRowIndex = 0,
    BugModuleRowIndex,
    BugTypeRowIndex,
    BugSeverityRowIndex,
    BugPriorityRowIndex,
    BugStatusRowIndex,
    BugActivatedCountRowIndex,
    BugConfirmedRowIndex,
    BugAssignedToRowIndex,
    BugOSRowIndex,
    BugBrowserRowIndex,
    BugKeywordsRowIndex,
    BasicInfoRowsCount,     //count
} BugBasicInfoSectionRowIndicies;

enum {
    BugFromCaseRowIndex = 0,
    BugToCaseRowIndex,
    CaseRowsCount,
} BugCaseSectionRowIndicies;

enum {
    BugOpenedByRowIndex = 0,
    BugOpenedBuildRowIndex,
    BugResolvedRowIndex,
    BugResolvedBuildRowIndex,
    BugResolutionRowIndex,
    BugClosedByRowIndex,
    BugLastEditedByRowIndex,
    LifetimeRowsCount,      //count
} LifetimeSectionRowIndicies;

enum {
    BugProjectRowIndex = 0,
    BugStoryRowIndex,
    BugTaskRowIndex,
    PSTRowsCount,           //count
} PSTSectionRowIndicies;

enum {
    BugMailtoRowIndex = 0,
    BugLinkedBugRowIndex,
    BugCaseRowIndex,
    BugToStoryRowIndex,
    BugToTaskRowIndex,
    MiscRowsCount,          //count
} MiscSectionRowIndicies;

@interface ZTCBugViewController ()
@property (assign, nonatomic) NSUInteger bugID;
@property (strong, nonatomic) NSDictionary *bugDict;
@property (strong, nonatomic) NSDictionary *productsDict;
@property (strong, nonatomic) NSDictionary *usersDict;
@property (strong, nonatomic) NSDictionary *cellKeyDict;
@property (strong, nonatomic) NSDictionary *cellValueDict;
@end

@implementation ZTCBugViewController

- (id)initWithID:(id) ID
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        _bugID = [ID intValue];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ZTCAPIClient* api = [ZTCAPIClient sharedClient];
    [api getPath:[ZTCAPIClient getUrlWithType:[ZTCAPIClient getRequestType] withParameters:@[@"m=bug",@"f=view",[NSString stringWithFormat:@"id=%u",self.bugID]]] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableDictionary *dict = [ZTCAPIClient dealWithZTStrangeJSON:JSON];
//            DLog(@"%@",dict);
            self.productsDict = dict[@"data"][@"products"];
            self.bugDict = dict[@"data"][@"bug"];
            self.usersDict = dict[@"data"][@"users"];
            self.cellKeyDict = @{[NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugProductRowIndex]: NSLocalizedString(@"bug product", nil),
                           [NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugModuleRowIndex]: NSLocalizedString(@"bug module", nil),
                           [NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugTypeRowIndex]: NSLocalizedString(@"bug type", nil),
                           [NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugSeverityRowIndex]: NSLocalizedString(@"bug severity", nil),
                           [NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugPriorityRowIndex]: NSLocalizedString(@"bug priority", nil),
                           [NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugStatusRowIndex]: NSLocalizedString(@"bug status", nil),
                           [NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugActivatedCountRowIndex]: NSLocalizedString(@"bug activatedCount", nil),
                           [NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugConfirmedRowIndex]: NSLocalizedString(@"bug confirmed", nil),
                           [NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugAssignedToRowIndex]: NSLocalizedString(@"bug assignedTo", nil),
                           [NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugOSRowIndex]: NSLocalizedString(@"bug os", nil),
                           [NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugBrowserRowIndex]: NSLocalizedString(@"bug browser", nil),
                           [NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugKeywordsRowIndex]: NSLocalizedString(@"bug keywords", nil),
                           //BugCaseSectionIndex
                           [NSString stringWithFormat:@"%u:%u",BugCaseSectionIndex,BugFromCaseRowIndex]: NSLocalizedString(@"bug fromCase", nil),
                           [NSString stringWithFormat:@"%u:%u",BugCaseSectionIndex,BugToCaseRowIndex]: NSLocalizedString(@"bug toCase", nil),
                           //BugLifetimeSectionIndex
                           [NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugOpenedByRowIndex]: NSLocalizedString(@"bug openedBy", nil),
                           [NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugOpenedBuildRowIndex]: NSLocalizedString(@"bug openedBuild", nil),
                           [NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugResolvedRowIndex]: NSLocalizedString(@"bug resolved", nil),
                           [NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugResolvedBuildRowIndex]: NSLocalizedString(@"bug resolvedBuild", nil),
                           [NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugResolutionRowIndex]: NSLocalizedString(@"bug resolution", nil),
                           [NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugClosedByRowIndex]: NSLocalizedString(@"bug closedBy", nil),
                           [NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugLastEditedByRowIndex]: NSLocalizedString(@"bug lastEditedBy", nil),
                           //BugPSTSectionIndex
                           [NSString stringWithFormat:@"%u:%u",BugPSTSectionIndex,BugProjectRowIndex]: NSLocalizedString(@"bug project", nil),
                           [NSString stringWithFormat:@"%u:%u",BugPSTSectionIndex,BugStoryRowIndex]: NSLocalizedString(@"bug story", nil),
                           [NSString stringWithFormat:@"%u:%u",BugPSTSectionIndex,BugTaskRowIndex]: NSLocalizedString(@"bug task", nil),
                           //BugMiscSectionIndex
                           [NSString stringWithFormat:@"%u:%u",BugMiscSectionIndex,BugMailtoRowIndex]: NSLocalizedString(@"bug mailto", nil),
                           [NSString stringWithFormat:@"%u:%u",BugMiscSectionIndex,BugLinkedBugRowIndex]: NSLocalizedString(@"bug linkBug", nil),
                           [NSString stringWithFormat:@"%u:%u",BugMiscSectionIndex,BugCaseRowIndex]: NSLocalizedString(@"bug case", nil),
                           [NSString stringWithFormat:@"%u:%u",BugMiscSectionIndex,BugToStoryRowIndex]: NSLocalizedString(@"bug toStory", nil),
                           [NSString stringWithFormat:@"%u:%u",BugMiscSectionIndex,BugToTaskRowIndex]: NSLocalizedString(@"bug toTask", nil)};
            self.cellValueDict = @{[NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugProductRowIndex]: (self.productsDict)[(self.bugDict)[@"product"]],
                             [NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugModuleRowIndex]: (self.bugDict)[@"module"],
                             [NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugTypeRowIndex]: [[NSBundle mainBundle] localizedStringForKey:([NSString stringWithFormat:@"bug type %@",(self.bugDict)[@"type"]]) value:@"" table:nil],
                             [NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugSeverityRowIndex]: [[NSBundle mainBundle] localizedStringForKey:([NSString stringWithFormat:@"bug severity %@",(self.bugDict)[@"severity"]]) value:@"" table:nil],
                             [NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugPriorityRowIndex]: [[NSBundle mainBundle] localizedStringForKey:([NSString stringWithFormat:@"bug pri %@",(self.bugDict)[@"pri"]]) value:@"" table:nil],
                             [NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugStatusRowIndex]: [[NSBundle mainBundle] localizedStringForKey:([NSString stringWithFormat:@"bug status %@",(self.bugDict)[@"status"]]) value:@"" table:nil],
                             [NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugActivatedCountRowIndex]: (self.bugDict)[@"activatedCount"],
                             [NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugConfirmedRowIndex]: [[NSBundle mainBundle] localizedStringForKey:([NSString stringWithFormat:@"bug confirmed %@",(self.bugDict)[@"confirmed"]]) value:@"" table:nil],
                             [NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugAssignedToRowIndex]: [NSString stringWithFormat:@"%@ %@ %@",(self.usersDict)[(self.bugDict)[@"assignedTo"]],NSLocalizedString(@"task at", nil),(self.bugDict)[@"assignedDate"]],
                             [NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugOSRowIndex]: [[NSBundle mainBundle] localizedStringForKey:([NSString stringWithFormat:@"bug os %@",(self.bugDict)[@"os"]]) value:@"" table:nil],
                             [NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugBrowserRowIndex]: [[NSBundle mainBundle] localizedStringForKey:([NSString stringWithFormat:@"bug browser %@",(self.bugDict)[@"browser"]]) value:@"" table:nil],
                             [NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugKeywordsRowIndex]: (self.bugDict)[@"keywords"],
                             //BugCaseSectionIndex
                             [NSString stringWithFormat:@"%u:%u",BugCaseSectionIndex,BugFromCaseRowIndex]: (self.bugDict)[@"caseTitle"]?(self.bugDict)[@"caseTitle"]:@"",
                             [NSString stringWithFormat:@"%u:%u",BugCaseSectionIndex,BugToCaseRowIndex]: ([(self.bugDict)[@"toCases"] count] == 1 ) ? (self.bugDict)[@"toCases"][[[(self.bugDict)[@"toCases"] allKeys] lastObject]] : ( ([(self.bugDict)[@"toCases"] count] == 0 ) ? @"" : [NSString stringWithFormat:@"%u %@",[(self.bugDict)[@"toCases"] count], [[NSBundle mainBundle] localizedStringForKey:@"bug toCase multi" value:@"" table:nil] ] ),
                             //BugLifetimeSectionIndex
                             [NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugOpenedByRowIndex]: [(self.bugDict)[@"openedDate"] isEqualToString:@""]?@"":[NSString stringWithFormat:@"%@ %@ %@",(self.usersDict)[(self.bugDict)[@"openedBy"]],NSLocalizedString(@"bug at", nil),(self.bugDict)[@"openedDate"]],
                             [NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugOpenedBuildRowIndex]: (self.bugDict)[@"openedBuild"],
                             [NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugResolvedRowIndex]: [(self.bugDict)[@"resolvedDate"] isEqualToString:@""]?@"":[NSString stringWithFormat:@"%@ %@ %@",(self.usersDict)[(self.bugDict)[@"resolvedBy"]],NSLocalizedString(@"bug at", nil),(self.bugDict)[@"resolvedDate"]],
                             [NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugResolvedBuildRowIndex]: (self.bugDict)[@"resolvedBuild"],
                             [NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugResolutionRowIndex]: [NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] localizedStringForKey:([NSString stringWithFormat:@"bug resolution %@",(self.bugDict)[@"resolution"]]) value:@"" table:nil],(self.bugDict)[@"duplicateBugTitle"]?[NSString stringWithFormat:@" #%@ %@",(self.bugDict)[@"duplicateBug"],(self.bugDict)[@"duplicateBugTitle"]]:@""],
                             [NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugClosedByRowIndex]: [(self.bugDict)[@"closedDate"] isEqualToString:@""]?@"":[NSString stringWithFormat:@"%@ %@ %@",(self.usersDict)[(self.bugDict)[@"closedBy"]],NSLocalizedString(@"bug at", nil),(self.bugDict)[@"closedDate"]],
                             [NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugLastEditedByRowIndex]: [(self.bugDict)[@"lastEditedDate"] isEqualToString:@""]?@"":[NSString stringWithFormat:@"%@ %@ %@",(self.usersDict)[(self.bugDict)[@"lastEditedBy"]],NSLocalizedString(@"bug at", nil),(self.bugDict)[@"lastEditedDate"]],
                             //BugPSTSectionIndex
                             [NSString stringWithFormat:@"%u:%u",BugPSTSectionIndex,BugProjectRowIndex]: [(self.bugDict)[@"project"] intValue]?(self.bugDict)[@"projectName"]:@"",
                             [NSString stringWithFormat:@"%u:%u",BugPSTSectionIndex,BugStoryRowIndex]: [(self.bugDict)[@"story"] intValue]?(self.bugDict)[@"storyTitle"]:@"",
                             [NSString stringWithFormat:@"%u:%u",BugPSTSectionIndex,BugTaskRowIndex]: [(self.bugDict)[@"task"] intValue]?(self.bugDict)[@"taskName"]:@"",
                             //BugMiscSectionIndex
                             [NSString stringWithFormat:@"%u:%u",BugMiscSectionIndex,BugMailtoRowIndex]: self.bugDict[@"mailto"],
                             [NSString stringWithFormat:@"%u:%u",BugMiscSectionIndex,BugLinkedBugRowIndex]: ([(self.bugDict)[@"linkBugTitles"] count] == 1 ) ? (self.bugDict)[@"linkBugTitles"][[[(self.bugDict)[@"linkBugTitles"] allKeys] lastObject]] : ( ([(self.bugDict)[@"linkBugTitles"] count] == 0 ) ? @"" : [NSString stringWithFormat:@"%u %@",[(self.bugDict)[@"linkBugTitles"] count], [[NSBundle mainBundle] localizedStringForKey:@"bug linkBug multi" value:@"" table:nil] ] ),
                             [NSString stringWithFormat:@"%u:%u",BugMiscSectionIndex,BugCaseRowIndex]: (self.bugDict)[@"caseTitle"],
                             [NSString stringWithFormat:@"%u:%u",BugMiscSectionIndex,BugToStoryRowIndex]: (self.bugDict)[@"toStoryTitle"],
                             [NSString stringWithFormat:@"%u:%u",BugMiscSectionIndex,BugToTaskRowIndex]: (self.bugDict)[@"toTaskTitle"]};
//            DLog(@"%@",cellValueDict);
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                self.title = [NSString stringWithFormat:@"%@ #%u",NSLocalizedString(@"bug", nil),self.bugID];
            });
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@",error);
        dispatch_sync(dispatch_get_main_queue(), ^{
            [ZTCNotice showErrorNoticeInView:self.view title:NSLocalizedString(@"error", nil) message:error.localizedDescription];
        });
    }];
    [api.operationQueue waitUntilAllOperationsAreFinished];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (!self.bugDict) {
        return 0;
    }
    return SectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.bugDict) {
        switch (section) {
            case BugSectionIndex:
                return InfoRowsCount;
                break;
            case BugBasicSectionIndex:
                return BasicInfoRowsCount;
                break;
            case BugCaseSectionIndex:
                return CaseRowsCount;
                break;
            case BugLifetimeSectionIndex:
                return LifetimeRowsCount;
                break;
            case BugPSTSectionIndex:
                return PSTRowsCount;
                break;
            case BugMiscSectionIndex:
                return MiscRowsCount;
                break;
            default:
                break;
        }
        
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case BugSectionIndex:
            sectionName = (self.bugDict)[@"title"];
            break;
        case BugBasicSectionIndex:
            sectionName = NSLocalizedString(@"bug basic info", nil);
            break;
        case BugCaseSectionIndex:
            sectionName = NSLocalizedString(@"bug case", nil);
            break;
        case BugLifetimeSectionIndex:
            sectionName = NSLocalizedString(@"bug lifetime", nil);
            break;
        case BugPSTSectionIndex:
            sectionName = NSLocalizedString(@"bug Project&Story&Task", nil);
            break;
        case BugMiscSectionIndex:
            sectionName = NSLocalizedString(@"bug misc", nil);
            break;
        default:
            sectionName = @"";
            break;
    }
//    DLog(@"%@",sectionName);
    return sectionName;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    switch (indexPath.section) {
        case BugSectionIndex:
            switch (indexPath.row) {
                case BugStepsRowIndex:{
                    NSString *desc = (self.bugDict)[@"steps"];
                    CGSize constraint = CGSizeMake(tableView.frame.size.width - (CELL_CONTENT_MARGIN * 2), 20000.0f);
                    
                    CGSize descSize = [desc sizeWithFont:[UIFont systemFontOfSize:SMALL_FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
                    CGFloat height = MAX(descSize.height, 44.0f);
                    
                    return height + (CELL_CONTENT_MARGIN * 2);
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    return CELL_CONTENT_DEFAULT_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
	switch (indexPath.section) {
        case BugSectionIndex:
            switch (indexPath.row) {
                case BugStepsRowIndex:{
                    cell = [tableView dequeueReusableCellWithIdentifier:@"BugStepsCell"];
                    if (!cell) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BugStepsCell"];
                    }
                    
                    NSString *desc = (self.bugDict)[@"steps"];
                    
                    [cell.textLabel setLineBreakMode:UILineBreakModeWordWrap];
                    [cell.textLabel setNumberOfLines:0];
                    //                    [[cell.textLabel layer] setBorderWidth:2.0f];
                    [cell.textLabel setFont:[UIFont systemFontOfSize:SMALL_FONT_SIZE]];
                    cell.textLabel.text = desc;
                    
                    break;
                }
                    
                default:
                    break;
            }
            break;
        case BugBasicSectionIndex:
        case BugCaseSectionIndex:
        case BugLifetimeSectionIndex:
        case BugPSTSectionIndex:
        case BugMiscSectionIndex:
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                          reuseIdentifier:@"BugCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BugCell"];
            }
            cell.textLabel.text = (self.cellKeyDict)[[NSString stringWithFormat:@"%u:%u",indexPath.section,indexPath.row]];
            cell.detailTextLabel.text = (self.cellValueDict)[[NSString stringWithFormat:@"%u:%u",indexPath.section,indexPath.row]];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        }
            break;
        default:
            NSLog(@"ERROR: section unknown!");
            break;
    }
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //todo
}

@end

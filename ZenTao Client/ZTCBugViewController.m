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

@end

@implementation ZTCBugViewController {
    @private
    NSUInteger bugID;
    NSDictionary *bugDict;
    NSDictionary *productsDict;
    NSDictionary *usersDict;
    NSDictionary *cellKeyDict;
    NSDictionary *cellValueDict;
}

- (id)initWithID:(id) ID
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        bugID = [ID intValue];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ZTCAPIClient* api = [ZTCAPIClient sharedClient];
    [api getPath:[ZTCAPIClient getUrlWithType:[ZTCAPIClient getRequestType],@"m=bug",@"f=view",[NSString stringWithFormat:@"id=%u",bugID],nil] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableDictionary *dict = [ZTCAPIClient dealWithZTStrangeJSON:JSON];
            //DLog(@"%@",dict);
            productsDict = [[dict objectForKey:@"data"] objectForKey:@"products"];
            bugDict = [[dict objectForKey:@"data"] objectForKey:@"bug"];
            usersDict = [[dict objectForKey:@"data"] objectForKey:@"users"];
            cellKeyDict = [NSDictionary dictionaryWithObjectsAndKeys:
                           //BugBasicSectionIndex
                           NSLocalizedString(@"bug product", nil),[NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugProductRowIndex],
                           NSLocalizedString(@"bug module", nil),[NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugModuleRowIndex],
                           NSLocalizedString(@"bug type", nil),[NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugTypeRowIndex],
                           NSLocalizedString(@"bug severity", nil),[NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugSeverityRowIndex],
                           NSLocalizedString(@"bug priority", nil),[NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugPriorityRowIndex],
                           NSLocalizedString(@"bug status", nil),[NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugStatusRowIndex],
                           NSLocalizedString(@"bug activatedCount", nil),[NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugActivatedCountRowIndex],
                           NSLocalizedString(@"bug confirmed", nil),[NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugConfirmedRowIndex],
                           NSLocalizedString(@"bug assignedTo", nil),[NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugAssignedToRowIndex],
                           NSLocalizedString(@"bug os", nil),[NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugOSRowIndex],
                           NSLocalizedString(@"bug browser", nil),[NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugBrowserRowIndex],
                           NSLocalizedString(@"bug keywords", nil),[NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugKeywordsRowIndex],
                           //BugCaseSectionIndex
                           NSLocalizedString(@"bug fromCase", nil),[NSString stringWithFormat:@"%u:%u",BugCaseSectionIndex,BugFromCaseRowIndex],
                           NSLocalizedString(@"bug toCase", nil),[NSString stringWithFormat:@"%u:%u",BugCaseSectionIndex,BugToCaseRowIndex],
                           //BugLifetimeSectionIndex
                           NSLocalizedString(@"bug openedBy", nil),[NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugOpenedByRowIndex],
                           NSLocalizedString(@"bug openedBuild", nil),[NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugOpenedBuildRowIndex],
                           NSLocalizedString(@"bug resolved", nil),[NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugResolvedRowIndex],
                           NSLocalizedString(@"bug resolvedBuild", nil),[NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugResolvedBuildRowIndex],
                           NSLocalizedString(@"bug resolution", nil),[NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugResolutionRowIndex],
                           NSLocalizedString(@"bug closedBy", nil),[NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugClosedByRowIndex],
                           NSLocalizedString(@"bug lastEditedBy", nil),[NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugLastEditedByRowIndex],
                           //BugPSTSectionIndex
                           NSLocalizedString(@"bug project", nil),[NSString stringWithFormat:@"%u:%u",BugPSTSectionIndex,BugProjectRowIndex],
                           NSLocalizedString(@"bug story", nil),[NSString stringWithFormat:@"%u:%u",BugPSTSectionIndex,BugStoryRowIndex],
                           NSLocalizedString(@"bug task", nil),[NSString stringWithFormat:@"%u:%u",BugPSTSectionIndex,BugTaskRowIndex],
                           //BugMiscSectionIndex
                           NSLocalizedString(@"bug mailto", nil),[NSString stringWithFormat:@"%u:%u",BugMiscSectionIndex,BugMailtoRowIndex],
                           NSLocalizedString(@"bug linkBug", nil),[NSString stringWithFormat:@"%u:%u",BugMiscSectionIndex,BugLinkedBugRowIndex],
                           NSLocalizedString(@"bug case", nil),[NSString stringWithFormat:@"%u:%u",BugMiscSectionIndex,BugCaseRowIndex],
                           NSLocalizedString(@"bug toStory", nil),[NSString stringWithFormat:@"%u:%u",BugMiscSectionIndex,BugToStoryRowIndex],
                           NSLocalizedString(@"bug toTask", nil),[NSString stringWithFormat:@"%u:%u",BugMiscSectionIndex,BugToTaskRowIndex],
                           nil];
            cellValueDict = [NSDictionary dictionaryWithObjectsAndKeys:
                             //BugBasicSectionIndex
                             [productsDict objectForKey:[bugDict objectForKey:@"product"]],[NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugProductRowIndex],
                             [bugDict objectForKey:@"module"],[NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugModuleRowIndex],
                             [[NSBundle mainBundle] localizedStringForKey:([NSString stringWithFormat:@"bug type %@",[bugDict objectForKey:@"type"]]) value:@"" table:nil],[NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugTypeRowIndex],
                             [[NSBundle mainBundle] localizedStringForKey:([NSString stringWithFormat:@"bug severity %@",[bugDict objectForKey:@"severity"]]) value:@"" table:nil],[NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugSeverityRowIndex],
                             [[NSBundle mainBundle] localizedStringForKey:([NSString stringWithFormat:@"bug pri %@",[bugDict objectForKey:@"pri"]]) value:@"" table:nil],[NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugPriorityRowIndex],
                             [[NSBundle mainBundle] localizedStringForKey:([NSString stringWithFormat:@"bug status %@",[bugDict objectForKey:@"status"]]) value:@"" table:nil],[NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugStatusRowIndex],
                             [bugDict objectForKey:@"activatedCount"],[NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugActivatedCountRowIndex],
                             [[NSBundle mainBundle] localizedStringForKey:([NSString stringWithFormat:@"bug confirmed %@",[bugDict objectForKey:@"confirmed"]]) value:@"" table:nil],[NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugConfirmedRowIndex],
                             [NSString stringWithFormat:@"%@ %@ %@",[usersDict objectForKey:[bugDict objectForKey:@"assignedTo"]],NSLocalizedString(@"task at", nil),[bugDict objectForKey:@"assignedDate"]],[NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugAssignedToRowIndex],
                             [[NSBundle mainBundle] localizedStringForKey:([NSString stringWithFormat:@"bug os %@",[bugDict objectForKey:@"os"]]) value:@"" table:nil],[NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugOSRowIndex],
                             [[NSBundle mainBundle] localizedStringForKey:([NSString stringWithFormat:@"bug browser %@",[bugDict objectForKey:@"browser"]]) value:@"" table:nil],[NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugBrowserRowIndex],
                             [bugDict objectForKey:@"keywords"],[NSString stringWithFormat:@"%u:%u",BugBasicSectionIndex,BugKeywordsRowIndex],
                             //BugCaseSectionIndex
                             [bugDict objectForKey:@"caseTitle"],[NSString stringWithFormat:@"%u:%u",BugCaseSectionIndex,BugFromCaseRowIndex],
                             ([[bugDict objectForKey:@"toCases"] count] == 1 ) ? [[bugDict objectForKey:@"toCases"] objectForKey: [[[bugDict objectForKey:@"toCases"] allKeys] lastObject] ] : [NSString stringWithFormat:@"%u %@",[[bugDict objectForKey:@"toCases"] count], [[NSBundle mainBundle] localizedStringForKey:@"bug toCase multi" value:@"" table:nil] ],[NSString stringWithFormat:@"%u:%u",BugCaseSectionIndex,BugToCaseRowIndex],
                             //BugLifetimeSectionIndex
                             [[bugDict objectForKey:@"openedDate"] isEqualToString:@""]?@"":[NSString stringWithFormat:@"%@ %@ %@",[usersDict objectForKey:[bugDict objectForKey:@"openedBy"]],NSLocalizedString(@"bug at", nil),[bugDict objectForKey:@"openedDate"]],[NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugOpenedByRowIndex],
                             [bugDict objectForKey:@"openedBuild"],[NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugOpenedBuildRowIndex],
                             [[bugDict objectForKey:@"resolvedDate"] isEqualToString:@""]?@"":[NSString stringWithFormat:@"%@ %@ %@",[usersDict objectForKey:[bugDict objectForKey:@"resolvedBy"]],NSLocalizedString(@"bug at", nil),[bugDict objectForKey:@"resolvedDate"]],[NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugResolvedRowIndex],
                             [bugDict objectForKey:@"resolvedBuild"],[NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugResolvedBuildRowIndex],
                             [NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] localizedStringForKey:([NSString stringWithFormat:@"bug resolution %@",[bugDict objectForKey:@"resolution"]]) value:@"" table:nil],[bugDict objectForKey:@"duplicateBugTitle"]?[NSString stringWithFormat:@" #%@ %@",[bugDict objectForKey:@"duplicateBug"],[bugDict objectForKey:@"duplicateBugTitle"]]:@""],[NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugResolutionRowIndex],
                             [[bugDict objectForKey:@"closedDate"] isEqualToString:@""]?@"":[NSString stringWithFormat:@"%@ %@ %@",[usersDict objectForKey:[bugDict objectForKey:@"closedBy"]],NSLocalizedString(@"bug at", nil),[bugDict objectForKey:@"closedDate"]],[NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugClosedByRowIndex],
                             [[bugDict objectForKey:@"lastEditedDate"] isEqualToString:@""]?@"":[NSString stringWithFormat:@"%@ %@ %@",[usersDict objectForKey:[bugDict objectForKey:@"lastEditedBy"]],NSLocalizedString(@"bug at", nil),[bugDict objectForKey:@"lastEditedDate"]],[NSString stringWithFormat:@"%u:%u",BugLifetimeSectionIndex,BugLastEditedByRowIndex],
                             //BugPSTSectionIndex
                             [[bugDict objectForKey:@"project"] intValue]?[bugDict objectForKey:@"projectName"]:@"",[NSString stringWithFormat:@"%u:%u",BugPSTSectionIndex,BugProjectRowIndex],
                             [[bugDict objectForKey:@"story"] intValue]?[bugDict objectForKey:@"storyTitle"]:@"",[NSString stringWithFormat:@"%u:%u",BugPSTSectionIndex,BugStoryRowIndex],
                             [[bugDict objectForKey:@"task"] intValue]?[bugDict objectForKey:@"taskName"]:@"",[NSString stringWithFormat:@"%u:%u",BugPSTSectionIndex,BugTaskRowIndex],
                             //BugMiscSectionIndex
                             bugDict[@"mailto"],[NSString stringWithFormat:@"%u:%u",BugMiscSectionIndex,BugMailtoRowIndex],
                             ([[bugDict objectForKey:@"linkBugTitles"] count] == 1 ) ? [[bugDict objectForKey:@"linkBugTitles"] objectForKey: [[[bugDict objectForKey:@"linkBugTitles"] allKeys] lastObject] ] : [NSString stringWithFormat:@"%u %@",[[bugDict objectForKey:@"linkBugTitles"] count], [[NSBundle mainBundle] localizedStringForKey:@"bug linkBug multi" value:@"" table:nil] ],[NSString stringWithFormat:@"%u:%u",BugMiscSectionIndex,BugLinkedBugRowIndex],
                             [bugDict objectForKey:@"caseTitle"],[NSString stringWithFormat:@"%u:%u",BugMiscSectionIndex,BugCaseRowIndex],
                             [bugDict objectForKey:@"toStoryTitle"],[NSString stringWithFormat:@"%u:%u",BugMiscSectionIndex,BugToStoryRowIndex],
                             [bugDict objectForKey:@"toTaskTitle"],[NSString stringWithFormat:@"%u:%u",BugMiscSectionIndex,BugToTaskRowIndex],
                             nil];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                self.title = [NSString stringWithFormat:@"%@ #%u",NSLocalizedString(@"bug", nil),bugID];
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
    if (!bugDict) {
        return 0;
    }
    return SectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (bugDict) {
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
            sectionName = [bugDict objectForKey:@"title"];
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
                    NSString *desc = [bugDict objectForKey:@"steps"];
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
    UITableViewCell * cell = nil;
	switch (indexPath.section) {
        case BugSectionIndex:
            switch (indexPath.row) {
                case BugStepsRowIndex:{
                    cell = [tableView dequeueReusableCellWithIdentifier:@"BugStepsCell"];
                    if (!cell) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BugStepsCell"];
                    }
                    
                    NSString *desc = [bugDict objectForKey:@"steps"];
                    
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
            cell.textLabel.text = [cellKeyDict objectForKey:[NSString stringWithFormat:@"%u:%u",indexPath.section,indexPath.row]];
            cell.detailTextLabel.text = [cellValueDict objectForKey:[NSString stringWithFormat:@"%u:%u",indexPath.section,indexPath.row]];
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

//
//  ZTCTaskViewController.m
//  ZenTao Client
//
//  Created by Puttin Wong on 3/20/13.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//

#import "ZTCTaskViewController.h"

#import "ZTCAPIClient.h"
#import <QuartzCore/QuartzCore.h>
#define FONT_SIZE 19.0f
#define SMALL_FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 300.0f
#define CELL_CONTENT_MARGIN 10.0f
#define CELL_CONTENT_DEFAULT_HEIGHT 44.0f
#define DEFAULT_GROUPED_HEADER_FONT_SIZE 23.0f
#define DEFAULT_GROUPED_HEADER_HEIGHT 22.0f
enum {
	TaskSectionIndex,
    TaskBasicSectionIndex,
} TaskSectionIndicies;

enum {
	TaskNameRowIndex,
//	TaskDescRowIndex,
} TaskInformationSectionRowIndicies;

enum {
    TaskProjectRowIndex,
    TaskModuleRowIndex,
    TaskStoryRowIndex,
    TaskAssignedToRowIndex,
    TaskTypeRowIndex,
    TaskStatusRowIndex,
    TaskPriRowIndex,
    TaskMailToRowIndex,
} TaskBasicInformationSectionRowIndicies;


@interface ZTCTaskViewController ()

@end

@implementation ZTCTaskViewController {
@private
    unsigned int taskID;
    NSDictionary *projectDict;
    NSDictionary *taskDict;
}

- (id)initWithTaskID:(unsigned int) ID
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        taskID = ID;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZTCAPIClient* api = [ZTCAPIClient sharedClient];
    [api getPath:[NSString stringWithFormat:@"task-view-%u.json",taskID] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSMutableDictionary *dict = [ZTCAPIClient dealWithZTStrangeJSON:JSON];
        projectDict = [[dict objectForKey:@"data"] objectForKey:@"project"];
        taskDict = [[dict objectForKey:@"data"] objectForKey:@"task"];
        //DLog(@"%@",taskDict);
        [self.tableView reloadData];
        self.title = [NSString stringWithFormat:@"%@ #%u",NSLocalizedString(@"task", nil),taskID];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@",error);
    }];
    [api.operationQueue waitUntilAllOperationsAreFinished];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case TaskSectionIndex:
            sectionName = [taskDict objectForKey:@"name"];
            break;
        case TaskBasicSectionIndex:
            sectionName = NSLocalizedString(@"task basic info", nil);
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case TaskSectionIndex:
        {
            NSString *name = [taskDict objectForKey:@"name"];
            CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
            CGSize nameSize = [name sizeWithFont:[UIFont systemFontOfSize:DEFAULT_GROUPED_HEADER_FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            CGFloat height = MAX(nameSize.height, DEFAULT_GROUPED_HEADER_HEIGHT);
            //DLog(@"%f",height);
            
            //[tableView headerViewForSection:section] iOS6 only...
            
            return height;
        }
            break;
            
        default:
            break;
    }
    
    
    return DEFAULT_GROUPED_HEADER_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    switch (indexPath.section) {
        case TaskSectionIndex:
            switch (indexPath.row) {
                case TaskNameRowIndex:{
                    //NSString *name = [taskDict objectForKey:@"name"];
                    NSString *desc = [taskDict objectForKey:@"desc"];
                    
                    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
                    
                    //CGSize nameSize = [name sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
                    CGSize descSize = [desc sizeWithFont:[UIFont systemFontOfSize:SMALL_FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
                    
                    CGFloat height = MAX(descSize.height, 44.0f);//nameSize.height+descSize.height;
                    
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if ([taskDict count]) {        
        switch (section) {
            case TaskSectionIndex:
                return 1;
                break;
            case TaskBasicSectionIndex:
                return 8;
                break;
            default:
                break;
        }
        //else if (section == 1) return 2;

    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#warning Incomplete method implementation.
    UITableViewCell * cell = nil;
	switch (indexPath.section) {
        case TaskSectionIndex:
            switch (indexPath.row) {
                case TaskNameRowIndex:{
                    //UILabel *nameLabel = nil;
                    UILabel *descLabel = nil;
                    cell = [tableView dequeueReusableCellWithIdentifier:@"TaskNameCell"];
                    if (!cell) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TaskNameCell"];
                        //name
//                        nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//                        [nameLabel setLineBreakMode:UILineBreakModeWordWrap];
//                        [nameLabel setMinimumFontSize:FONT_SIZE];
//                        [nameLabel setNumberOfLines:0];
//                        [nameLabel setFont:[UIFont systemFontOfSize:FONT_SIZE]];
//                        [nameLabel setBackgroundColor:[UIColor clearColor]];
//                        [nameLabel setTag:1];
//                        //[[nameLabel layer] setBorderWidth:2.0f];
//                        [[cell contentView] addSubview:nameLabel];
                        
                        //desc
                        descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                        [descLabel setLineBreakMode:UILineBreakModeWordWrap];
                        [descLabel setMinimumFontSize:SMALL_FONT_SIZE];
                        [descLabel setNumberOfLines:0];
                        [descLabel setFont:[UIFont systemFontOfSize:SMALL_FONT_SIZE]];
                        [descLabel setBackgroundColor:[UIColor clearColor]];
                        [descLabel setTag:2];
                        //[[descLabel layer] setBorderWidth:2.0f];
                        [[cell contentView] addSubview:descLabel];
                    }
                    //cell.textLabel.text = [taskDict objectForKey:@"name"];
                    //[cell.textLabel setLineBreakMode:UILineBreakModeWordWrap];
                    
                    //NSString *name = [taskDict objectForKey:@"name"];
                    NSString *desc = [taskDict objectForKey:@"desc"];
                    
                    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
                    
                    //CGSize nameSize = [name sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
                    CGSize descSize = [desc sizeWithFont:[UIFont systemFontOfSize:SMALL_FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
                    //name
//                    if (!nameLabel)
//                        nameLabel = (UILabel*)[cell viewWithTag:1];
//                    
//                    [nameLabel setText:name];
//                    [nameLabel setFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), nameSize.height)];
                    //desc
                    if (!descLabel)
                        descLabel = (UILabel*)[cell viewWithTag:2];
                    
                    [descLabel setText:desc];
                    [descLabel setFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), MAX(descSize.height, 44.0f))];
                    //DLog(@"%@",[descLabel backgroundColor]);
                    
                    break;
                }
//                case TaskDescRowIndex:
//                    cell = [tableView dequeueReusableCellWithIdentifier:@"TaskDescCell"];
//                    if (!cell) {
//                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TaskDescCell"];
//                    }
//                    cell.textLabel.text = [taskDict objectForKey:@"desc"];
//                    [cell.textLabel setLineBreakMode:UILineBreakModeWordWrap];
//                    break;
                default:
                    break;
            }
            break;
        case TaskBasicSectionIndex:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                          reuseIdentifier:@"TaskBasicInfoCell"];
            switch (indexPath.row) {
                case TaskProjectRowIndex:
                    cell.textLabel.text = NSLocalizedString(@"task project", nil);
                    cell.detailTextLabel.text = [projectDict objectForKey:@"name"];
                    break;
                case TaskModuleRowIndex:
                    cell.textLabel.text = NSLocalizedString(@"task module", nil);
                    cell.detailTextLabel.text = [taskDict objectForKey:@"module"];
                    break;
                case TaskStoryRowIndex:
                    cell.textLabel.text = NSLocalizedString(@"task story", nil);
                    cell.detailTextLabel.text = [[taskDict objectForKey:@"story"] intValue]?[taskDict objectForKey:@"storyTitle"]:nil;
                    break;
                case TaskAssignedToRowIndex:
                    cell.textLabel.text = NSLocalizedString(@"task assignedto", nil);
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ %@",[taskDict objectForKey:@"assignedToRealName"],NSLocalizedString(@"task assignedto at", nil),[taskDict objectForKey:@"assignedDate"]];
                    break;
                case TaskTypeRowIndex:{
                    cell.textLabel.text = NSLocalizedString(@"task type", nil);
                    NSString *type = [NSString stringWithFormat:@"task type %@",[taskDict objectForKey:@"type"]];
                    cell.detailTextLabel.text = NSLocalizedString(type, nil);
                    break;
                }
                case TaskStatusRowIndex:{
                    cell.textLabel.text = NSLocalizedString(@"task status", nil);
                    NSString *status = [NSString stringWithFormat:@"task status %@",[taskDict objectForKey:@"status"]];
                    cell.detailTextLabel.text = NSLocalizedString(status, nil);
                    break;
                }
                case TaskPriRowIndex:
                    cell.textLabel.text = NSLocalizedString(@"task pri", nil);
                    cell.detailTextLabel.text = [taskDict objectForKey:@"pri"];
                    break;
                case TaskMailToRowIndex:
                    cell.textLabel.text = NSLocalizedString(@"task mailto", nil);
                    cell.detailTextLabel.text = [taskDict objectForKey:@"mailto"];
                    break;
                default:
                    break;
            }
            break;
        default:
            NSLog(@"ERROR: section unknown!");
            break;
    }
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end

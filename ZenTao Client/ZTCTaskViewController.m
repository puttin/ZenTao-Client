//
//  ZTCTaskViewController.m
//  ZenTao Client
//
//  Created by Puttin Wong on 3/20/13.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//

#import "ZTCTaskViewController.h"

#import "ZTCAPIClient.h"
enum {
	TaskSectionIndex,
    TaskBasicSectionIndex,
} TaskSectionIndicies;

enum {
	TaskNameRowIndex,
	TaskDescRowIndex,
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
    ZTCAPIClient* api = [ZTCAPIClient sharedClient];
    [api getPath:[NSString stringWithFormat:@"task-view-%u.json",taskID] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSMutableDictionary *dict = [ZTCAPIClient dealWithZTStrangeJSON:JSON];
        projectDict = [[dict objectForKey:@"data"] objectForKey:@"project"];
        taskDict = [[dict objectForKey:@"data"] objectForKey:@"task"];
        //DLog(@"%@",taskDict);
        [self.tableView reloadData];
        self.title = [NSString stringWithFormat:@"%@ %u",NSLocalizedString(@"task", nil),taskID];
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
        case TaskBasicSectionIndex:
            sectionName = NSLocalizedString(@"task basic info", nil);
            break;
            // ...
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if ([taskDict count]) {        
        switch (section) {
            case TaskSectionIndex:
                return 2;
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
                case TaskNameRowIndex:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"TaskNameCell"];
                    if (!cell) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TaskNameCell"];
                    }
                    cell.textLabel.text = [taskDict objectForKey:@"name"];
                    break;
                case TaskDescRowIndex:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"TaskDescCell"];
                    if (!cell) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TaskDescCell"];
                    }
                    cell.textLabel.text = [taskDict objectForKey:@"desc"];
                    break;
                default:
                    break;
            }
            break;
        case TaskBasicSectionIndex:
            switch (indexPath.row) {
                case TaskProjectRowIndex:
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                                   reuseIdentifier:@"TaskBasicInfoCell"];
                    cell.textLabel.text = NSLocalizedString(@"task project", nil);
                    cell.detailTextLabel.text = [projectDict objectForKey:@"name"];
                    break;
                case TaskModuleRowIndex:
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                                  reuseIdentifier:@"TaskBasicInfoCell"];
                    cell.textLabel.text = NSLocalizedString(@"task module", nil);
                    cell.detailTextLabel.text = [taskDict objectForKey:@"module"];
                    break;
                case TaskStoryRowIndex:
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                                  reuseIdentifier:@"TaskBasicInfoCell"];
                    cell.textLabel.text = NSLocalizedString(@"task story", nil);
                    cell.detailTextLabel.text = [[taskDict objectForKey:@"story"] intValue]?[taskDict objectForKey:@"storyTitle"]:nil;
                    break;
                case TaskAssignedToRowIndex:
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                                  reuseIdentifier:@"TaskBasicInfoCell"];
                    cell.textLabel.text = NSLocalizedString(@"task assignedto", nil);
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ %@",[taskDict objectForKey:@"assignedToRealName"],NSLocalizedString(@"task assignedto at", nil),[taskDict objectForKey:@"assignedDate"]];
                    break;
                case TaskTypeRowIndex:{
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                                  reuseIdentifier:@"TaskBasicInfoCell"];
                    cell.textLabel.text = NSLocalizedString(@"task type", nil);
                    NSString *type = [NSString stringWithFormat:@"task type %@",[taskDict objectForKey:@"type"]];
                    cell.detailTextLabel.text = NSLocalizedString(type, nil);
                    break;
                }
                case TaskStatusRowIndex:{
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                                  reuseIdentifier:@"TaskBasicInfoCell"];
                    cell.textLabel.text = NSLocalizedString(@"task status", nil);
                    NSString *status = [NSString stringWithFormat:@"task status %@",[taskDict objectForKey:@"status"]];
                    cell.detailTextLabel.text = NSLocalizedString(status, nil);
                    break;
                }
                case TaskPriRowIndex:
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                                  reuseIdentifier:@"TaskBasicInfoCell"];
                    cell.textLabel.text = NSLocalizedString(@"task pri", nil);
                    cell.detailTextLabel.text = [taskDict objectForKey:@"pri"];
                    break;
                case TaskMailToRowIndex:
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                                  reuseIdentifier:@"TaskBasicInfoCell"];
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

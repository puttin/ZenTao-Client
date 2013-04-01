//
//  ZTCTaskListViewController.m
//  ZenTao Client
//
//  Created by Puttin Wong on 3/19/13.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//

#import "ZTCTaskListViewController.h"

#import "ZTCAPIClient.h"
#import "ZTCTaskViewController.h"
#import "ZTCNotice.h"
@interface ZTCTaskListViewController ()

@end

@implementation ZTCTaskListViewController {
@private
    NSMutableArray *taskArray;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getTaskListWithType:TaskLoadIndex,@"m=my",@"f=task",nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [taskArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TaskListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    
    cell.textLabel.text = [[taskArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    //cell.textLabel.font= [UIFont fontWithName:@"STHeitiSC-Medium" size:[UIFont systemFontSize]];
    
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
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    // Navigation logic may go here. Create and push another view controller.
    
    //DLog(@"%d",[[[taskArray objectAtIndex:indexPath.row] objectForKey:@"id"] intValue]);
    ZTCTaskViewController *detailViewController = [[ZTCTaskViewController alloc] initWithTaskID:[[[taskArray objectAtIndex:indexPath.row] objectForKey:@"id"] intValue]];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    
}
#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)getTaskListWithType:(NSUInteger)type,... {
    ZTCAPIClient* api = [ZTCAPIClient sharedClient];
    va_list args;
    va_start(args, type);
    [api getPath:[ZTCAPIClient getUrlWithType:[ZTCAPIClient getRequestType] withParameters:args] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSMutableDictionary *dict = [ZTCAPIClient dealWithZTStrangeJSON:JSON];
        switch (type) {
            case TaskLoadIndex:{
                taskArray = [[dict objectForKey:@"data"] objectForKey:@"tasks"];
                [self.tableView reloadData];
                break;
            }
            case TaskRefreshIndex:{
                taskArray = [[dict objectForKey:@"data"] objectForKey:@"tasks"];
                //DLog(@"%@",taskArray);
                [self doneLoadingTableViewData];
                [self.tableView reloadData];
                break;
            }
            case TaskAppendIndex:{
                [taskArray addObjectsFromArray:[[dict objectForKey:@"data"] objectForKey:@"tasks"]];
                break;
            }
            default:
                break;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@",error);
        switch (type) {
            case TaskLoadIndex:{
                break;
            }
            case TaskRefreshIndex:{
                [self doneLoadingTableViewData];
                break;
            }
            case TaskAppendIndex:{
                break;
            }
            default:
                break;
        }
        [ZTCNotice showErrorNoticeInView:self.view title:NSLocalizedString(@"error", nil) message:error.localizedDescription];
    }];
    va_end(args);
}

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
    [self getTaskListWithType:TaskRefreshIndex,@"m=my",@"f=task",nil];
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	//[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

@end

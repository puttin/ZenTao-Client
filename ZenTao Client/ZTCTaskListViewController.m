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
    dispatch_queue_t updateQueue;
    NSMutableArray *taskArray;
    NSString *taskType;
    NSString *orderBy;
    NSUInteger recTotal;
    NSUInteger recPerPage;
    NSUInteger pageID;
    //type=assignedto&orderBy=id_desc&recTotal=1&recPerPage=5&pageID=1
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        taskType = @"assignedto";
        orderBy = @"id_desc";
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    updateQueue = dispatch_queue_create("com.puttinwong.ZenTao-Client.taskQueue", NULL);
    
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
    if (_loadMoreFooterView == nil) {
		
		PWLoadMoreTableFooterView *view = [[PWLoadMoreTableFooterView alloc] init];
		view.delegate = self;
		_loadMoreFooterView = view;
		
	}
    
    self.tableView.tableFooterView = _loadMoreFooterView;
    
    [self getTaskListWithType:TaskLoadIndex,@"m=my",@"f=task",nil];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _loadMoreFooterView = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
	_dataSourceIsLoading = YES;
    ZTCAPIClient* api = [ZTCAPIClient sharedClient];
    va_list args;
    va_start(args, type);
    [api getPath:[ZTCAPIClient getUrlWithType:[ZTCAPIClient getRequestType] withParameters:args] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        dispatch_async(updateQueue, ^{
            NSMutableDictionary *dict = [ZTCAPIClient dealWithZTStrangeJSON:JSON];
            NSDictionary *pager = [[dict objectForKey:@"data"] objectForKey:@"pager"];
            recTotal = [[pager objectForKey:@"recTotal"] intValue];
            recPerPage = [[pager objectForKey:@"recPerPage"] intValue];
            pageID = [[pager objectForKey:@"pageID"] intValue];
            //DLog(@"pager:%@",pager);
            if (pageID >= [[pager objectForKey:@"pageTotal"] intValue]) {
                _loadMoreAllLoaded = YES;
            } else
                _loadMoreAllLoaded = NO;
            //DLog(@"%@",dict);
            switch (type) {
                case TaskLoadIndex:{
                    taskArray = [[dict objectForKey:@"data"] objectForKey:@"tasks"];
                    break;
                }
                case TaskRefreshIndex:{
                    taskArray = [[dict objectForKey:@"data"] objectForKey:@"tasks"];
                    break;
                }
                case TaskAppendIndex:{
                    [taskArray addObjectsFromArray:[[dict objectForKey:@"data"] objectForKey:@"tasks"]];
                    break;
                }
                default:
                    break;
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self doneLoadMoreTableViewData];
                [self.tableView reloadData];
                if (type == TaskRefreshIndex) {
                    [self doneRefreshTableViewData];
                    [self resetLoadMore];
                }
            });
            _dataSourceIsLoading = NO;
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"ERROR: %@",error);
            switch (type) {
                case TaskLoadIndex:{
                    break;
                }
                case TaskRefreshIndex:{
                    [self doneRefreshTableViewData];
                    break;
                }
                case TaskAppendIndex:{
                    break;
                }
                default:
                    break;
            }
            [self doneLoadMoreTableViewData];
            [ZTCNotice showErrorNoticeInView:self.view title:NSLocalizedString(@"error", nil) message:error.localizedDescription];
        });
        _dataSourceIsLoading = NO;
    }];
    va_end(args);
}

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	//DLog(@"reloadTableViewDataSource");
	_reloading = YES;
    [self getTaskListWithType:TaskRefreshIndex,@"m=my",@"f=task",nil];
}

- (void)doneRefreshTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}
- (void)doneLoadMoreTableViewData {
	
	//  model should call this when its done loading
	[_loadMoreFooterView pwLoadMoreTableDataSourceDidFinishedLoading];
	
}

- (void)resetLoadMore {
    //data source should call this when it can load more
    [_loadMoreFooterView resetLoadMore];
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
	//DLog(@"egoRefreshTableHeaderDidTriggerRefresh");
	[self reloadTableViewDataSource];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}
#pragma mark -
#pragma mark PWLoadMoreTableFooterDelegate Methods

- (void)pwLoadMore {
    [self getTaskListWithType:TaskAppendIndex,@"m=my",@"f=task",[NSString stringWithFormat:@"type=%@",taskType],[NSString stringWithFormat:@"orderBy=%@",orderBy],[NSString stringWithFormat:@"recTotal=%u",recTotal],[NSString stringWithFormat:@"recPerPage=%u",recPerPage],[NSString stringWithFormat:@"pageID=%u",pageID+1],nil];
}


- (BOOL)pwLoadMoreTableDataSourceIsLoading {
    return _dataSourceIsLoading;
}
- (BOOL)pwLoadMoreTableDataSourceAllLoaded {
    return _loadMoreAllLoaded;
}
@end

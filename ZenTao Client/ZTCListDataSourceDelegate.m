//
//  ZTCListDataSourceDelegate.m
//  ZenTao Client
//
//  Created by Puttin Wong on 13-4-19.
//  Copyright (c) 2013年 Puttin Wong. All rights reserved.
//

#import "ZTCListDataSourceDelegate.h"
#import "ZTCAPIClient.h"
#import "ZTCNotice.h"
#import "ZTCTaskViewController.h"

@implementation ZTCListDataSourceDelegate

@synthesize listViewDelegate = _listViewDelegate;
@synthesize updateQueue = _updateQueue;
@synthesize itemArray = _itemArray;
@synthesize itemType = _itemType;
@synthesize orderBy = _orderBy;
@synthesize recTotal = _recTotal;
@synthesize recPerPage = _recPerPage;
@synthesize pageID = _pageID;

- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
        [self addObserver:self forKeyPath:@"listViewDelegate" options:NSKeyValueObservingOptionNew context:nil];
        _updateQueue = dispatch_queue_create("com.puttinwong.ZenTao-Client.itemUpdateQueue", NULL);
        _itemType = @"assignedto";//todo
        _orderBy = @"id_desc";
    }
    return self;
}
#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //	DLog(@"scrollViewDidScroll");
	[_listViewDelegate.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    //    DLog(@"scrollViewDidEndDragging");
	[_listViewDelegate.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    // Navigation logic may go here. Create and push another view controller.
    
    //DLog(@"%d",[[[taskArray objectAtIndex:indexPath.row] objectForKey:@"id"] intValue]);
    UIViewController *detailViewController = [[ZTCTaskViewController alloc] initWithTaskID:[[[_listViewDelegate.dataSourceDelegate.itemArray objectAtIndex:indexPath.row] objectForKey:@"id"] intValue]];
    // ...
    // Pass the selected object to the new view controller.
    [_listViewDelegate.navigationController pushViewController:detailViewController animated:YES];
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
    return [_itemArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TaskListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    cell.textLabel.text = [[_itemArray objectAtIndex:indexPath.row] objectForKey:@"name"]; // name TODO
    //cell.textLabel.font= [UIFont fontWithName:@"STHeitiSC-Medium" size:[UIFont systemFontSize]];
    
    return cell;
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	//DLog(@"egoRefreshTableHeaderDidTriggerRefresh");
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
    [self getItemListWithType:ItemRefreshIndex,@"m=my",@"f=task",nil];//todo
	
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
    [self getItemListWithType:ItemAppendIndex,@"m=my",@"f=task",[NSString stringWithFormat:@"type=%@",_itemType],[NSString stringWithFormat:@"orderBy=%@",_orderBy],[NSString stringWithFormat:@"recTotal=%u",_recTotal],[NSString stringWithFormat:@"recPerPage=%u",_recPerPage],[NSString stringWithFormat:@"pageID=%u",_pageID+1],nil];//todo
}


- (BOOL)pwLoadMoreTableDataSourceIsLoading {
    return _dataSourceIsLoading;
}
- (BOOL)pwLoadMoreTableDataSourceAllLoaded {
    return _loadMoreAllLoaded;
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)getItemListWithType:(NSUInteger)type,... {
	_dataSourceIsLoading = YES;
    ZTCAPIClient* api = [ZTCAPIClient sharedClient];
    va_list args;
    va_start(args, type);
    [api getPath:[ZTCAPIClient getUrlWithType:[ZTCAPIClient getRequestType] withParameters:args] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        dispatch_async(_updateQueue, ^{
            NSMutableDictionary *dict = [ZTCAPIClient dealWithZTStrangeJSON:JSON];
            NSDictionary *pager = [[dict objectForKey:@"data"] objectForKey:@"pager"];
            _recTotal = [[pager objectForKey:@"recTotal"] intValue];
            _recPerPage = [[pager objectForKey:@"recPerPage"] intValue];
            _pageID = [[pager objectForKey:@"pageID"] intValue];
            //DLog(@"pager:%@",pager);
            if (_pageID >= [[pager objectForKey:@"pageTotal"] intValue]) {
                _loadMoreAllLoaded = YES;
            } else
                _loadMoreAllLoaded = NO;
            //DLog(@"%@",dict);
            switch (type) {
                case ItemLoadIndex:{
                    _itemArray = [[dict objectForKey:@"data"] objectForKey:@"tasks"];//todo
                    break;
                }
                case ItemRefreshIndex:{
                    _itemArray = [[dict objectForKey:@"data"] objectForKey:@"tasks"];//todo
                    break;
                }
                case ItemAppendIndex:{
                    [_itemArray addObjectsFromArray:[[dict objectForKey:@"data"] objectForKey:@"tasks"]];//todo
                    break;
                }
                default:
                    break;
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self doneLoadMoreTableViewData];
                [_listViewDelegate.tableView reloadData];
                if (type == ItemRefreshIndex) {
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
                case ItemLoadIndex:{
                    break;
                }
                case ItemRefreshIndex:{
                    [self doneRefreshTableViewData];
                    break;
                }
                case ItemAppendIndex:{
                    break;
                }
                default:
                    break;
            }
            [self doneLoadMoreTableViewData];
            [ZTCNotice showErrorNoticeInView:_listViewDelegate.tableView title:NSLocalizedString(@"error", nil) message:error.localizedDescription];
        });
        _dataSourceIsLoading = NO;
    }];
    va_end(args);
}

- (void)doneRefreshTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
    
	[_listViewDelegate.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_listViewDelegate.tableView];
}
- (void)doneLoadMoreTableViewData {
	
	//  model should call this when its done loading
	[_listViewDelegate.loadMoreFooterView pwLoadMoreTableDataSourceDidFinishedLoading];
	
}

- (void)resetLoadMore {
    //data source should call this when it can load more
    [_listViewDelegate.loadMoreFooterView resetLoadMore];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    DLog(@"observeValueForKeyPath");
    if ([keyPath isEqual:@"listViewDelegate"]) {
        [self getItemListWithType:ItemLoadIndex,@"m=my",@"f=task",nil];//todo
    }
    /*
     Be sure to call the superclass's implementation *if it implements it*.
     NSObject does not implement the method.
     */
//    [super observeValueForKeyPath:keyPath
//                         ofObject:object
//                           change:change
//                          context:context];
}

#pragma mark - dealloc

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"listViewDelegate" context:nil];
}

@end
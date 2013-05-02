//
//  ZTCListDataSourceDelegate.m
//  ZenTao Client
//
//  Created by Puttin Wong on 13-4-19.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//

#import "ZTCListDataSourceDelegate.h"
#import "ZTCAPIClient.h"
#import "ZTCNotice.h"
#import "ZTCListViewController.h"

@implementation ZTCListDataSourceDelegate {
    dispatch_queue_t updateQueue;
    
    NSString *itemName;
    NSString *itemsNameInJSON;
    NSString *itemViewController;
    
    NSUInteger parametersCount;
}

- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
        [self addObserver:self forKeyPath:@"listViewDelegate" options:NSKeyValueObservingOptionNew context:nil];
        updateQueue = dispatch_queue_create("com.puttinwong.ZenTao-Client.itemUpdateQueue", NULL);
        [self initParameterArray];
    }
    return self;
}

- (void)initParameterArray {
    parametersCount = 0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSUInteger currentModule = [defaults integerForKey:kCurrentModule];
    NSUInteger currentMethod = [defaults integerForKey:kCurrentMethod];
    NSDictionary *parameterDict = [defaults arrayForKey:@"module"][currentModule][@"method"][currentMethod];
    NSMutableArray *parameterArray = [[NSMutableArray alloc] init];
    itemName = parameterDict[@"itemName"];
    itemsNameInJSON = parameterDict[@"itemsNameInJSON"];
    itemViewController = parameterDict[@"itemViewController"];
//    NSLog(@"%@",parameterDict[@"parameters"]);
    [(NSArray*)parameterDict[@"parameters"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([[(NSDictionary*)obj objectForKey:@"option"] boolValue]) {
            parameterArray[idx] = [NSString stringWithFormat:@"%@=%@",obj[@"keyword"],obj[@"option.default"]];
        } else {
            parameterArray[idx] = [NSString stringWithFormat:@"%@=%@",obj[@"keyword"],obj[@"value"]];
        }
        parametersCount++;
    }];
    self.parameterArray = parameterArray;
//    NSLog(@"%@",parameterArray);
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
    // Navigation logic may go here. Create and push another view controller.
    // Pass the selected object to the new view controller.
    UIViewController *detailViewController = nil;
    Class c = NSClassFromString(itemViewController);
    SEL s = NSSelectorFromString(@"initWithID:");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    detailViewController = [[c alloc] performSelector:s withObject:[[_listViewDelegate.dataSourceDelegate.itemArray objectAtIndex:indexPath.row] objectForKey:@"id"]];
#pragma clang diagnostic pop

    if (detailViewController) {
        [_listViewDelegate.navigationController pushViewController:detailViewController animated:YES];
    }
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
    cell.textLabel.text = [[_itemArray objectAtIndex:indexPath.row] objectForKey:itemName];
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
	[self refreshTable];
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
    [self getItemListWithType:ItemAppendIndex withParameters:self.parameterArray];
}


- (BOOL)pwLoadMoreTableDataSourceIsLoading {
    return _dataSourceIsLoading;
}
- (BOOL)pwLoadMoreTableDataSourceAllLoaded {
    return _loadMoreAllLoaded;
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)refreshTable {
    [self getItemListWithType:ItemRefreshIndex withParameters:[self.parameterArray subarrayWithRange:NSMakeRange(0, parametersCount)]];
}

- (void)getItemListWithType:(NSUInteger)type withParameters:(NSArray *)parameters {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _dataSourceIsLoading = YES;
        ZTCAPIClient* api = [ZTCAPIClient sharedClient];
        [api getPath:[ZTCAPIClient getUrlWithType:[ZTCAPIClient getRequestType] withParameters:parameters] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
            dispatch_async(updateQueue, ^{
                NSMutableDictionary *dict = [ZTCAPIClient dealWithZTStrangeJSON:JSON];
                NSDictionary *pagerDict = [[dict objectForKey:@"data"] objectForKey:@"pager"];
                if (pagerDict) {
                    if ([self.parameterArray count] == (parametersCount+3)) {
                        [self.parameterArray removeObjectsInRange:NSMakeRange(parametersCount, 3)];
                    }
                    [self.parameterArray addObject:[NSString stringWithFormat:@"recTotal=%u",[[pagerDict objectForKey:@"recTotal"] intValue]]];
                    [self.parameterArray addObject:[NSString stringWithFormat:@"recPerPage=%u",[[pagerDict objectForKey:@"recPerPage"] intValue]]];
                    [self.parameterArray addObject:[NSString stringWithFormat:@"pageID=%u",[[pagerDict objectForKey:@"pageID"] intValue]+1]];
                    if ([[pagerDict objectForKey:@"pageID"] intValue] >= [[pagerDict objectForKey:@"pageTotal"] intValue]) {
                        _loadMoreAllLoaded = YES;
                    } else
                        _loadMoreAllLoaded = NO;
                }
                //DLog(@"%@",dict);
                switch (type) {
                    case ItemLoadIndex:{
                        _itemArray = [[dict objectForKey:@"data"] objectForKey:itemsNameInJSON];
                        break;
                    }
                    case ItemRefreshIndex:{
                        _itemArray = [[dict objectForKey:@"data"] objectForKey:itemsNameInJSON];
                        break;
                    }
                    case ItemAppendIndex:{
                        [_itemArray addObjectsFromArray:[[dict objectForKey:@"data"] objectForKey:itemsNameInJSON]];
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
    });
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
//    DLog(@"observeValueForKeyPath");
    if ([keyPath isEqual:@"listViewDelegate"]) {
        [self refreshTable];
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
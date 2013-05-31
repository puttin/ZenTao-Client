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

enum {
    ItemLoadIndex,
    ItemRefreshIndex,
    ItemAppendIndex,
} ItemUpdateIndicies;

@interface ZTCListDataSourceDelegate ()
@property(nonatomic,strong) NSMutableArray *itemArray;
@property(nonatomic,strong) NSMutableArray *parameterArray;
@property (assign, nonatomic) BOOL reloading;
@property (assign, nonatomic) BOOL dataSourceIsLoading;
@property (assign, nonatomic) BOOL loadMoreAllLoaded;
@property (assign, nonatomic) dispatch_queue_t updateQueue;
@property (strong, nonatomic) NSString *itemName;
@property (strong, nonatomic) NSString *itemsNameInJSON;;
@property (strong, nonatomic) NSString *itemViewController;
@property (assign, nonatomic) NSUInteger parametersCount;
@property (strong, nonatomic) NSString *viewControllerTitle;
@end

@implementation ZTCListDataSourceDelegate

- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
        [self addObserver:self forKeyPath:@"listView" options:NSKeyValueObservingOptionNew context:nil];
        _updateQueue = dispatch_queue_create("com.puttinwong.ZenTao-Client.itemUpdateQueue", NULL);
        [self initParameterArray];
    }
    return self;
}

- (void)initParameterArray {
    _parametersCount = 0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSUInteger currentModuleGroup = [defaults integerForKey:kCurrentModuleGroup];
    NSUInteger currentModule = [defaults integerForKey:kCurrentModule];
    NSUInteger currentMethod = [defaults integerForKey:kCurrentMethod];
    NSDictionary *parameterDict = [defaults arrayForKey:@"group"][currentModuleGroup][@"groupModule"][currentModule][@"method"][currentMethod];
    NSMutableArray *parameterArray = [[NSMutableArray alloc] init];
    _itemName = parameterDict[@"itemName"];
    _itemsNameInJSON = parameterDict[@"itemsNameInJSON"];
    _itemViewController = parameterDict[@"itemViewController"];
//    NSLog(@"%@",parameterDict[@"parameters"]);
    [(NSArray*)parameterDict[@"parameters"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([[(NSDictionary*)obj objectForKey:@"option"] boolValue]) {
            parameterArray[idx] = [NSString stringWithFormat:@"%@=%@",obj[@"keyword"],obj[@"option.default"]];
        } else {
            parameterArray[idx] = [NSString stringWithFormat:@"%@=%@",obj[@"keyword"],obj[@"value"]];
        }
        _parametersCount++;
    }];
    _parameterArray = parameterArray;
//    NSLog(@"%@",parameterArray);
    _viewControllerTitle = parameterDict[@"title"];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //	DLog(@"scrollViewDidScroll");
	[self.listView.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    //    DLog(@"scrollViewDidEndDragging");
	[self.listView.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    // Pass the selected object to the new view controller.
    UIViewController *detailViewController = nil;
    Class c = NSClassFromString(self.itemViewController);
    SEL s = NSSelectorFromString(@"initWithID:");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    detailViewController = [[c alloc] performSelector:s withObject:[[self.itemArray objectAtIndex:indexPath.row] objectForKey:@"id"]];
#pragma clang diagnostic pop

    if (detailViewController) {
        [self.listView.navigationController pushViewController:detailViewController animated:YES];
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
    return [self.itemArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TaskListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    cell.textLabel.text = [[self.itemArray objectAtIndex:indexPath.row] objectForKey:self.itemName];
    //cell.textLabel.font= [UIFont fontWithName:@"STHeitiSC-Medium" size:[UIFont systemFontSize]];
    
    return cell;
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	//DLog(@"egoRefreshTableHeaderDidTriggerRefresh");
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	self.reloading = YES;
	[self refreshTable];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return self.reloading; // should return if data source model is reloading
	
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
    return self.dataSourceIsLoading;
}
- (BOOL)pwLoadMoreTableDataSourceAllLoaded {
    return self.loadMoreAllLoaded;
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)refreshTable {
    [self getItemListWithType:ItemRefreshIndex withParameters:[self.parameterArray subarrayWithRange:NSMakeRange(0, self.parametersCount)]];
}

- (void)getItemListWithType:(NSUInteger)type withParameters:(NSArray *)parameters {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.dataSourceIsLoading = YES;
        ZTCAPIClient* api = [ZTCAPIClient sharedClient];
        [api getPath:[ZTCAPIClient getUrlWithType:[ZTCAPIClient getRequestType] withParameters:parameters] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
            dispatch_async(self.updateQueue, ^{
                NSMutableDictionary *dict = [ZTCAPIClient dealWithZTStrangeJSON:JSON];
                NSDictionary *pagerDict = [[dict objectForKey:@"data"] objectForKey:@"pager"];
                if (pagerDict) {
                    if ([self.parameterArray count] == (self.parametersCount+3)) {
                        [self.parameterArray removeObjectsInRange:NSMakeRange(self.parametersCount, 3)];
                    }
                    [self.parameterArray addObject:[NSString stringWithFormat:@"recTotal=%u",[[pagerDict objectForKey:@"recTotal"] intValue]]];
                    [self.parameterArray addObject:[NSString stringWithFormat:@"recPerPage=%u",[[pagerDict objectForKey:@"recPerPage"] intValue]]];
                    [self.parameterArray addObject:[NSString stringWithFormat:@"pageID=%u",[[pagerDict objectForKey:@"pageID"] intValue]+1]];
                    if ([[pagerDict objectForKey:@"pageID"] intValue] >= [[pagerDict objectForKey:@"pageTotal"] intValue]) {
                        self.loadMoreAllLoaded = YES;
                    } else
                        self.loadMoreAllLoaded = NO;
                }
                //DLog(@"%@",dict);
                switch (type) {
                    case ItemLoadIndex:{
                        self.itemArray = [[dict objectForKey:@"data"] objectForKey:self.itemsNameInJSON];
                        break;
                    }
                    case ItemRefreshIndex:{
                        self.itemArray = [[dict objectForKey:@"data"] objectForKey:self.itemsNameInJSON];
                        break;
                    }
                    case ItemAppendIndex:{
                        [self.itemArray addObjectsFromArray:[[dict objectForKey:@"data"] objectForKey:self.itemsNameInJSON]];
                        break;
                    }
                    default:
                        break;
                }
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self doneLoadMoreTableViewData];
                    [self.listView.tableView reloadData];
                    if (type == ItemRefreshIndex) {
                        [self doneRefreshTableViewData];
                        [self resetLoadMore];
                    }
                });
                self.dataSourceIsLoading = NO;
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
                [ZTCNotice showErrorNoticeInView:self.listView.tableView title:NSLocalizedString(@"error", nil) message:error.localizedDescription];
            });
            self.dataSourceIsLoading = NO;
        }];
    });
}

- (void)doneRefreshTableViewData{
	
	//  model should call this when its done loading
	self.reloading = NO;
    
	[self.listView.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.listView.tableView];
}
- (void)doneLoadMoreTableViewData {
	
	//  model should call this when its done loading
	[self.listView.loadMoreFooterView pwLoadMoreTableDataSourceDidFinishedLoading];
	
}

- (void)resetLoadMore {
    //data source should call this when it can load more
    [self.listView.loadMoreFooterView resetLoadMore];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
//    DLog(@"observeValueForKeyPath");
    if ([keyPath isEqual:@"listView"]) {
        self.listView.title = NSLocalizedString(self.viewControllerTitle, nil);
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
    [self removeObserver:self forKeyPath:@"listView" context:nil];
    dispatch_release(_updateQueue);
}

@end
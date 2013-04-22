//
//  ZTCListViewController.m
//  ZenTao Client
//
//  Created by Puttin Wong on 13-4-19.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//

#import "ZTCListViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "PWLoadMoreTableFooterView.h"
#import "ZTCListDataSourceDelegate.h"

@interface ZTCListViewController ()

@end

@implementation ZTCListViewController

@synthesize refreshHeaderView = _refreshHeaderView;
@synthesize loadMoreFooterView = _loadMoreFooterView;

@synthesize tableView = _tableView;
@synthesize dataSourceDelegate = _dataSourceDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.tableView = [[UITableView alloc] init];
    self.view = self.tableView;
    
    //dataSourceDelegate and delegate
    self.dataSourceDelegate = [[ZTCListDataSourceDelegate alloc] init];
    [self.dataSourceDelegate setType:listTypeMyBug];
    
    //refreshHeaderView init
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self.dataSourceDelegate;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
    //loadMoreFooterView init
    if (_loadMoreFooterView == nil) {
		
		PWLoadMoreTableFooterView *view = [[PWLoadMoreTableFooterView alloc] init];
		view.delegate = self.dataSourceDelegate;
		_loadMoreFooterView = view;
		
	}
    
    self.tableView.tableFooterView = _loadMoreFooterView;
    
    //tableView delegate and dataSourceDelegate
    self.tableView.delegate = self.dataSourceDelegate;
    self.tableView.dataSource = self.dataSourceDelegate;
    
    //let the delegate can control listView
    self.dataSourceDelegate.listViewDelegate = self;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //when user get back, deselect the row.
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
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

@end

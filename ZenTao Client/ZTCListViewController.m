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
#import "IIViewDeckController.h"

@interface ZTCListViewController () <IIViewDeckControllerDelegate>

@end

@implementation ZTCListViewController {
    NSUInteger listType;
}

@synthesize refreshHeaderView = _refreshHeaderView;
@synthesize loadMoreFooterView = _loadMoreFooterView;

@synthesize tableView = _tableView;
@synthesize dataSourceDelegate = _dataSourceDelegate;

- (id)init {
    //Init with default type
    NSLog(@"WARNING: SHOULD NOT invoke 'init' to init listViewController, use 'initWithType'");
    return [self initWithType:ListTypeMyTask];
}

- (id)initWithType:(NSUInteger)type {
    self = [super init];
    if (self) {
        listType = type;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //viewDeck
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(showMenu)];
    
    self.tableView = [[UITableView alloc] init];
    self.view = self.tableView;
    
    //dataSourceDelegate and delegate
    self.dataSourceDelegate = [[ZTCListDataSourceDelegate alloc] init];
    [self.dataSourceDelegate setType:listType];
    
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

#pragma mark - ViewDeck & its delegate

- (void)viewDeckController:(IIViewDeckController *)viewDeckController willOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    [(IIViewDeckController*)self.viewDeckController.leftController openLeftView];
}

- (void)viewDeckController:(IIViewDeckController*)viewDeckController willCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    [(IIViewDeckController*)self.viewDeckController.leftController closeLeftView];
}

- (void) showMenu {
    [self.viewDeckController toggleLeftView];
}

@end

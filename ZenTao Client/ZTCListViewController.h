//
//  ZTCListViewController.h
//  ZenTao Client
//
//  Created by Puttin Wong on 13-4-19.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    ListTypeMyTask = 0,
    listTypeMyBug,
} ListType;

@class EGORefreshTableHeaderView;
@class PWLoadMoreTableFooterView;
@class ZTCListDataSourceDelegate;
@interface ZTCListViewController : UIViewController
@property(nonatomic,strong) EGORefreshTableHeaderView *refreshHeaderView;
@property(nonatomic,strong) PWLoadMoreTableFooterView *loadMoreFooterView;
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) ZTCListDataSourceDelegate *dataSourceDelegate;

- (id)initWithType:(NSUInteger)type;
@end

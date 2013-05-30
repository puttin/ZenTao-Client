//
//  ZTCListDataSourceDelegate.h
//  ZenTao Client
//
//  Created by Puttin Wong on 13-4-19.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGORefreshTableHeaderView.h"
#import "PWLoadMoreTableFooterView.h"

@class ZTCListViewController;
@interface ZTCListDataSourceDelegate : NSObject <UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,PWLoadMoreTableFooterDelegate>
@property(nonatomic,weak) ZTCListViewController *listView;
@end

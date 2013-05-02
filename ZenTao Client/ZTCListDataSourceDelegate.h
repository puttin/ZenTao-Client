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

enum {
    ItemLoadIndex,
    ItemRefreshIndex,
    ItemAppendIndex,
} ItemUpdateIndicies;

@class ZTCListViewController;
@interface ZTCListDataSourceDelegate : NSObject <UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,PWLoadMoreTableFooterDelegate> {
	BOOL _reloading;
	BOOL _dataSourceIsLoading;
    bool _loadMoreAllLoaded;
}
@property(nonatomic,weak) ZTCListViewController *listViewDelegate;
@property(nonatomic,strong) NSMutableArray *itemArray;
@property(nonatomic,strong) NSMutableArray *parameterArray;

@end

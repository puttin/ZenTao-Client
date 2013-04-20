//
//  ZTCListDataSourceDelegate.h
//  ZenTao Client
//
//  Created by Puttin Wong on 13-4-19.
//  Copyright (c) 2013年 Puttin Wong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGORefreshTableHeaderView.h"
#import "PWLoadMoreTableFooterView.h"
#import "ZTCListViewController.h"

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

@property(nonatomic,assign) dispatch_queue_t updateQueue;

@property(nonatomic,strong) NSMutableArray *itemArray;
@property(nonatomic,strong) NSString *itemType;
@property(nonatomic,strong) NSString *orderBy;

//pager
@property(nonatomic,assign) NSUInteger recTotal;
@property(nonatomic,assign) NSUInteger recPerPage;
@property(nonatomic,assign) NSUInteger pageID;

- (id)init;
- (void)getItemListWithType:(NSUInteger)type,...;

@end

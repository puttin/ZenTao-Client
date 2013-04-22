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
    ListTypeMyTask = 0,
    listTypeMyBug,
} ListType;

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
@property(nonatomic,assign) NSUInteger type;
@property(nonatomic,strong) NSString *itemType;
@property(nonatomic,strong) NSString *orderBy;
@property(nonatomic,strong) NSString *itemName;
@property(nonatomic,strong) NSString *module;
@property(nonatomic,strong) NSString *function;
@property(nonatomic,strong) NSString *itemsNameInJSON;

//pager
@property(nonatomic,assign) NSUInteger recTotal;
@property(nonatomic,assign) NSUInteger recPerPage;
@property(nonatomic,assign) NSUInteger pageID;

- (id)init;

@end

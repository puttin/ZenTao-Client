//
//  ZTCTaskListViewController.h
//  ZenTao Client
//
//  Created by Puttin Wong on 3/19/13.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "PWLoadMoreTableFooterView.h"

enum {
    TaskLoadIndex,
    TaskRefreshIndex,
    TaskAppendIndex,
} TaskUpdateIndicies;

@interface ZTCTaskListViewController : UITableViewController <EGORefreshTableHeaderDelegate,PWLoadMoreTableFooterDelegate> {
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
    PWLoadMoreTableFooterView *_loadMoreFooterView;
	BOOL _loadMoreLoading;
    bool _loadMoreAllLoaded;
}

@end

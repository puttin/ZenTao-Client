//
//  ZTCTaskListViewController.h
//  ZenTao Client
//
//  Created by Puttin Wong on 3/19/13.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface ZTCTaskListViewController : UITableViewController <EGORefreshTableHeaderDelegate> {
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
}

@end

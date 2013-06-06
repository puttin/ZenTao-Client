//
//  ZTCMenuViewController.h
//  ZenTao Client
//
//  Created by Puttin Wong on 04/27/2013.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MenuType) {
    MenuTypeMainMenu = 0,
    MenuTypeSubMenu,
};

@interface ZTCMenuViewController : UITableViewController
- (id)initWithType:(MenuType)type;
@end

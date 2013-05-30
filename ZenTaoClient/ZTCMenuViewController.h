//
//  ZTCMenuViewController.h
//  ZenTao Client
//
//  Created by Puttin Wong on 04/27/2013.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    MenuTypeMainMenu = 0,
    MenuTypeSubMenu,
} MenuType;

@interface ZTCMenuViewController : UITableViewController
- (id)initWithType:(NSUInteger)type;
@end

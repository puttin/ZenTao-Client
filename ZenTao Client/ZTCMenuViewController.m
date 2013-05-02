//
//  ZTCMenuViewController.m
//  ZenTao Client
//
//  Created by Puttin Wong on 04/27/2013.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//

#import "ZTCMenuViewController.h"
#import "IIViewDeckController.h"

@interface ZTCMenuViewController ()

@end

@implementation ZTCMenuViewController {
    NSUInteger menuType;
    NSArray *menuItems;
}

- (id)init {
    NSLog(@"WARNING: SHOULD NOT invoke 'init' to init menuViewController, use 'initWithType'");
    return nil;
}

- (id)initWithType:(NSUInteger)type
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // Custom initialization
        menuType = type;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.scrollsToTop = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:[defaults integerForKey:@"defaultModule"] forKey:kCurrentModule];
    [defaults setInteger:[defaults integerForKey:@"defaultMethod"] forKey:kCurrentMethod];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch (menuType) {
        case MenuTypeMainMenu: {
            menuItems = [defaults objectForKey:@"module"];
        }
            break;
        case MenuTypeSubMenu: {
            NSUInteger currentModule = [defaults integerForKey:kCurrentModule];
            menuItems = [defaults objectForKey:@"module"][currentModule][@"method"];
        }
            break;
        default:
            break;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch (menuType) {
        case MenuTypeMainMenu: {
            NSUInteger currentModule = [defaults integerForKey:kCurrentModule];
            NSIndexPath *ip = [NSIndexPath indexPathForRow:currentModule inSection:0];
            [self.tableView selectRowAtIndexPath:ip animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
            break;
        case MenuTypeSubMenu: {
            NSUInteger currentMethod = [defaults integerForKey:kCurrentMethod];
            NSIndexPath *ip = [NSIndexPath indexPathForRow:currentMethod inSection:0];
            [self.tableView selectRowAtIndexPath:ip animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    cell.textLabel.text = NSLocalizedString(menuItems[indexPath.row][@"name"], nil);
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch (menuType) {
        case MenuTypeMainMenu: {
            [defaults setInteger:indexPath.row forKey:kCurrentModule];
            [defaults setInteger:0 forKey:kCurrentMethod];
        }
            break;
        case MenuTypeSubMenu: {
            [defaults setInteger:indexPath.row forKey:kCurrentMethod];
        }
            break;
        default:
            break;
    }
    Class ZTCListViewController = NSClassFromString(@"ZTCListViewController");
    id list = [[ZTCListViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:list];
    [self.viewDeckController.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
        [controller setCenterController:nav];
    }];
}

@end

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
@property (assign, nonatomic) NSUInteger menuType;
@property (strong, nonatomic) NSArray *menuItems;
@end

@implementation ZTCMenuViewController

- (id)init {
    NSLog(@"WARNING: SHOULD NOT invoke 'init' to init menuViewController, use 'initWithType'");
    return nil;
}

- (id)initWithType:(NSUInteger)type
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // Custom initialization
        _menuType = type;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.scrollsToTop = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:[defaults integerForKey:@"defaultModuleGroup"] forKey:kCurrentModuleGroup];
    [defaults setInteger:[defaults integerForKey:@"defaultModule"] forKey:kCurrentModule];
    [defaults setInteger:[defaults integerForKey:@"defaultMethod"] forKey:kCurrentMethod];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch (self.menuType) {
        case MenuTypeMainMenu: {
            self.menuItems = [defaults objectForKey:@"group"];
        }
            break;
        case MenuTypeSubMenu: {
            NSUInteger currentModuleGroup = [defaults integerForKey:kCurrentModuleGroup];
            NSUInteger currentModule = [defaults integerForKey:kCurrentModule];
            self.menuItems = [defaults objectForKey:@"group"][currentModuleGroup][@"groupModule"][currentModule][@"method"];
            [self.tableView reloadData];
        }
            break;
        default:
            break;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch (self.menuType) {
        case MenuTypeMainMenu: {
            NSUInteger currentModuleGroup = [defaults integerForKey:kCurrentModuleGroup];
            NSUInteger currentModule = [defaults integerForKey:kCurrentModule];
            NSIndexPath *ip = [NSIndexPath indexPathForRow:currentModule inSection:currentModuleGroup];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (self.menuType) {
        case MenuTypeMainMenu: {
            NSString *groupName = NSLocalizedString(self.menuItems[section][@"groupName"], nil);
            groupName = (groupName && groupName.length)?groupName:nil;
            return groupName;
        }
            break;
        case MenuTypeSubMenu: {
            return nil;
        }
            break;
        default:
            break;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    switch (self.menuType) {
        case MenuTypeMainMenu: {
            return [self.menuItems count];
        }
            break;
        case MenuTypeSubMenu: {
            return 1;
        }
            break;
        default:
            break;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (self.menuType) {
        case MenuTypeMainMenu: {
            return [self.menuItems[section][@"groupModule"] count];
        }
            break;
        case MenuTypeSubMenu: {
            return [self.menuItems count];
        }
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    switch (self.menuType) {
        case MenuTypeMainMenu: {
            cell.textLabel.text = NSLocalizedString(self.menuItems[indexPath.section][@"groupModule"][indexPath.row][@"name"], nil);
        }
            break;
        case MenuTypeSubMenu: {
            cell.textLabel.text = NSLocalizedString(self.menuItems[indexPath.row][@"name"], nil);
        }
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch (self.menuType) {
        case MenuTypeMainMenu: {
            [defaults setInteger:indexPath.section forKey:kCurrentModuleGroup];
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
    
    NSUInteger currentModuleGroup = [defaults integerForKey:kCurrentModuleGroup];
    NSUInteger currentModule = [defaults integerForKey:kCurrentModule];
    NSUInteger currentMethod = [defaults integerForKey:kCurrentMethod];
    NSString *className = [defaults arrayForKey:@"group"][currentModuleGroup][@"groupModule"][currentModule][@"method"][currentMethod][@"viewController"];
//    NSLog(@"%@",className);
    Class ViewController = NSClassFromString(className);
    id viewController = [[ViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self.viewDeckController.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
        [controller setCenterController:nav];
    }];
}

@end

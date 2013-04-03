//
//  ZTCUserSettingsViewController.m
//  ZenTao Client
//
//  Created by Puttin Wong on 3/22/13.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//

#import "ZTCUserSettingsViewController.h"
#import "ZTCAPIClient.h"
#import "ZTCTaskListViewController.h"
#import "ZTCNotice.h"

enum {
	AccountSectionIndex,
    URLSectionIndex,
    ModeSectionIndex,
} UserInfoSectionIndicies;

enum {
	AccountRowIndex,
    PasswordRowIndex,
} AccountSectionRowIndicies;

enum {
	UrlRowIndex,
} UrlSectionRowIndicies;

enum {
	ModeRowIndex,
} ModeSectionRowIndicies;

enum {
    kTextFieldTag = 1000,
    kSegTag = 2000,
} TagIndicies;

@interface ZTCUserSettingsViewController ()

@end

@implementation ZTCUserSettingsViewController{
}

@synthesize accountTextFiled = _accountTextFiled;
@synthesize passwordTextFiled = _passwordTextFiled;
@synthesize urlTextFiled = _urlTextFiled;

- (id)init{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        [self initAccountTextFiled];
        [self initPasswordTextFiled];
        [self initUrlTextFiled];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        _accountTextFiled.text = [defaults stringForKey:@"account"];
        _passwordTextFiled.text = [defaults stringForKey:@"password"];
        _urlTextFiled.text = [defaults stringForKey:@"url"];
    }
    return self;
}

- (UITextField*)getBasicTextField {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 185, 30)];
    textField.clearsOnBeginEditing = NO;
    textField.adjustsFontSizeToFitWidth = YES;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.backgroundColor = [UIColor clearColor];
    textField.tag = kTextFieldTag;
    [textField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
    return textField;
}

- (void)initAccountTextFiled {
    _accountTextFiled= [self getBasicTextField];
    
    _accountTextFiled.placeholder = @"demo";
    _accountTextFiled.keyboardType = UIKeyboardTypeDefault;
    _accountTextFiled.returnKeyType = UIReturnKeyNext;
}

- (void)initPasswordTextFiled {
    _passwordTextFiled= [self getBasicTextField];
    
    _passwordTextFiled.placeholder = @"123456";
    _passwordTextFiled.keyboardType = UIKeyboardTypeDefault;
    _passwordTextFiled.returnKeyType = UIReturnKeyNext;
}

- (void)initUrlTextFiled {
    _urlTextFiled= [self getBasicTextField];
    
    _urlTextFiled.placeholder = @"demo.zentao.net";
    _urlTextFiled.keyboardType = UIKeyboardTypeDefault;
    _urlTextFiled.returnKeyType = UIReturnKeyDone;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(registerUserSettings)];
    self.title = NSLocalizedString(@"login", nil);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
/*
- (void)loadView
{
    [super loadView];
}
*/
- (void)registerUserSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([ZTCAPIClient loginWithAccount:_accountTextFiled.text Password:_passwordTextFiled.text BaseURL:_urlTextFiled.text]) {
        [defaults setObject:_accountTextFiled.text forKey:@"account"];
        [defaults setObject:_passwordTextFiled.text forKey:@"password"];
        [defaults setObject:_urlTextFiled.text forKey:@"url"];
        [defaults synchronize];
        
        [self.parentViewController dismissModalViewControllerAnimated:YES];
        UITableViewController *viewController = [[ZTCTaskListViewController alloc] initWithStyle:UITableViewStylePlain];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
        [[[[UIApplication sharedApplication] delegate] window] setRootViewController:nav];
        [ZTCNotice showSuccessNoticeInView:viewController.view title:NSLocalizedString(@"login success title", nil)];
    } else {
        //login fail;
        [ZTCNotice showErrorNoticeInView:self.view title:NSLocalizedString(@"login fail title", nil) message:NSLocalizedString(@"login fail message", nil)];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"]];
    switch (section)
    {
        case AccountSectionIndex:
            sectionName = NSLocalizedStringFromTableInBundle(@"Basic Group", @"Root", bundle, nil);
            break;
        case URLSectionIndex:
            sectionName = NSLocalizedStringFromTableInBundle(@"URL Group", @"Root", bundle, nil);
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *sectionFooter;
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"]];
    switch (section)
    {
        case AccountSectionIndex:
            sectionFooter = NSLocalizedStringFromTableInBundle(@"Basic Group Desc", @"Root", bundle, nil);
            break;
        case URLSectionIndex:
            sectionFooter = NSLocalizedStringFromTableInBundle(@"URL Group Desc", @"Root", bundle, nil);
            break;
        default:
            sectionFooter = @"";
            break;
    }
    return sectionFooter;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case AccountSectionIndex:
            return 2;
            break;
        case URLSectionIndex:
            return 1;
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = nil;
    UITableViewCell *cell = nil;
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"]];
    switch (indexPath.section) {
        case AccountSectionIndex:
        case URLSectionIndex:
        {
            CellIdentifier = @"TextFieldCell";
            cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryNone;
                
            }
            for(UIView *subview in [cell subviews]) {
                if([subview isKindOfClass:[UITextField class]]) {
                    [subview removeFromSuperview];
                }
            }
            switch (indexPath.section) {
                case AccountSectionIndex:
                    switch (indexPath.row) {
                        case AccountRowIndex:
                        {
                            [cell.contentView addSubview:_accountTextFiled];
                            cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Account", @"Root", bundle, nil);
                        }
                            break;
                        case PasswordRowIndex:
                        {
                            [cell.contentView addSubview:_passwordTextFiled];
                            cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Password", @"Root", bundle, nil);
                        }
                            break;
                        default:
                            break;
                    }
                    break;
                case URLSectionIndex:
                    switch (indexPath.row) {
                        case UrlRowIndex:
                        {
                            [cell.contentView addSubview:_urlTextFiled];
                            cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"URL", @"Root", bundle, nil);
                        }
                            break;
                        default:
                            break;
                    }
                    break;
                default:
                    break;
            }
            
        }
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - TextField delegate

- (void)textFieldDone:(UITextField*)textField
{
    [textField resignFirstResponder];
    UITextField *nextField = nil;
    NSIndexPath *newPath = nil;
    if (textField == _accountTextFiled) {
        newPath = [NSIndexPath indexPathForRow:PasswordRowIndex inSection:AccountSectionIndex];
        nextField = _passwordTextFiled;
    } else if (textField == _passwordTextFiled) {
        newPath = [NSIndexPath indexPathForRow:UrlRowIndex inSection:URLSectionIndex];
        nextField = _urlTextFiled;
    } else {
        //
    }
    if (newPath && [[self.tableView indexPathsForVisibleRows] containsObject:newPath]) {
        if ([nextField canBecomeFirstResponder]) {
            [self.tableView scrollToRowAtIndexPath:newPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            [nextField becomeFirstResponder];
        }
    }
}

@end

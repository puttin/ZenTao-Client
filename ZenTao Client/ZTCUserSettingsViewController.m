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
    AccountTagIndex,
    PasswordTagIndex,
    URLTagIndex,
} TextFieldTagIndicies;
@interface ZTCUserSettingsViewController ()

@end

@implementation ZTCUserSettingsViewController{
    BOOL keyboardIsShown;
    NSString *account;
    NSString *password;
    NSString *url;
    NSUInteger mode;
}

- (id)init{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"]];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        account = [defaults stringForKey:@"account"];
        password = [defaults stringForKey:@"password"];
        url = [defaults stringForKey:@"url"];
        mode = [[defaults stringForKey:@"requestType"] isEqualToString:NSLocalizedStringFromTableInBundle(@"RequestType GET", @"Root", bundle, nil)]?0:1;
    }
    return self;
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
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"]];
    NSString *type = mode?NSLocalizedStringFromTableInBundle(@"RequestType PATH_INFO", @"Root", bundle, nil):NSLocalizedStringFromTableInBundle(@"RequestType GET", @"Root", bundle, nil);
    if ([ZTCAPIClient loginWithAccount:account Password:password Mode:type BaseURL:url]) {
        [defaults setObject:account forKey:@"account"];
        [defaults setObject:password forKey:@"password"];
        [defaults setObject:url forKey:@"url"];
        [defaults setObject:type forKey:@"requestType"];
        [defaults synchronize];
        /*
         DLog(@"%@",[defaults stringForKey:@"account"]);
         DLog(@"%@",[defaults stringForKey:@"password"]);
         DLog(@"%@",[defaults stringForKey:@"url"]);
         DLog(@"%@",[defaults stringForKey:@"requestType"]);
         */
         
        [self.parentViewController dismissModalViewControllerAnimated:YES];
        UITableViewController *viewController = [[ZTCTaskListViewController alloc] initWithStyle:UITableViewStylePlain];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
        [[[[UIApplication sharedApplication] delegate] window] setRootViewController:nav];
    } else {
        //login fail;
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
        case ModeSectionIndex:
            sectionName = NSLocalizedStringFromTableInBundle(@"RequestType Group", @"Root", bundle, nil);
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
        case ModeSectionIndex:
            sectionFooter = NSLocalizedStringFromTableInBundle(@"RequestType Group Desc", @"Root", bundle, nil);
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
        case ModeSectionIndex:
            return 1;
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = nil;
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"]];
    switch (indexPath.section) {
        case AccountSectionIndex:
        case URLSectionIndex:
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryNone;
                
            }
            UITextField *textField = nil;
            textField = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 185, 30)];
            textField.clearsOnBeginEditing = NO;
            textField.adjustsFontSizeToFitWidth = YES;
            //textField.backgroundColor = [UIColor whiteColor];
            textField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
            textField.backgroundColor = [UIColor clearColor];
            //[textField setDelegate:self];
            [textField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
            [textField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
            switch (indexPath.section) {
                case AccountSectionIndex:
                    switch (indexPath.row) {
                        case AccountRowIndex:
                        {
                            textField.tag = AccountTagIndex;
                            textField.placeholder = @"demo";
                            textField.text = account;
                            textField.keyboardType = UIKeyboardTypeDefault;
                            textField.returnKeyType = UIReturnKeyNext;
                            cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Account", @"Root", bundle, nil);
                            
                        }
                            break;
                        case PasswordRowIndex:
                        {
                            textField.tag = PasswordTagIndex;
                            textField.placeholder = @"123456";
                            textField.text = password;
                            textField.keyboardType = UIKeyboardTypeDefault;
                            textField.returnKeyType = UIReturnKeyNext;
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
                            textField.tag = URLTagIndex;
                            textField.placeholder = @"demo.zentao.net";
                            textField.text = url;
                            textField.keyboardType = UIKeyboardTypeURL;
                            textField.returnKeyType = UIReturnKeyDone;
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
            for(UIView *subview in [cell subviews]) {
                if([subview isKindOfClass:[UITextField class]]) {
                    [subview removeFromSuperview];
                }
            }
            [cell addSubview:textField];
            
        }
            break;
        case ModeSectionIndex:
        {
            CellIdentifier = @"SegCell";
            cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryNone;
                
            }
            switch (indexPath.row) {
                case ModeRowIndex:
                {
                    UISegmentedControl *seg = nil;
                    seg = [[UISegmentedControl alloc] initWithItems:[[NSArray alloc]initWithObjects:NSLocalizedStringFromTableInBundle(@"RequestType GET", @"Root", bundle, nil),NSLocalizedStringFromTableInBundle(@"RequestType PATH_INFO", @"Root", bundle, nil),nil]];
                    seg.selectedSegmentIndex = mode;
                    cell.backgroundColor = [UIColor clearColor];
                    cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
                    //DLog(@"%f %f",cell.frame.size.width,cell.frame.size.height);
                    [seg setCenter:CGPointMake(cell.frame.size.width/2, cell.frame.size.height/2)];
                    [seg addTarget:self action:@selector(segChanged:) forControlEvents:UIControlEventValueChanged];
                    for(UIView *subview in [cell subviews]) {
                        if([subview isKindOfClass:[UISegmentedControl class]]) {
                            [subview removeFromSuperview];
                        }
                    }
                    [cell addSubview:seg];
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - TextField delegate

- (IBAction)textFieldDone:(id)sender
{
    NSIndexPath *newPath = nil;
    switch (((UITextField*)sender).tag) {
        case AccountTagIndex:
            account = [(UITextField *)sender text];
            newPath = [NSIndexPath indexPathForRow:PasswordRowIndex inSection:AccountSectionIndex];
            break;
        case PasswordTagIndex:
            password = [(UITextField *)sender text];
            newPath = [NSIndexPath indexPathForRow:UrlRowIndex inSection:URLSectionIndex];
            break;
        case URLTagIndex:
            url = [(UITextField *)sender text];
            break;

        default:
            break;
    }
    
    if (newPath) {
        UITableViewCell *nextCell = [self.tableView cellForRowAtIndexPath:newPath];
        if (nextCell) {
            UITextField *nextField = nil;
            for (UIView *oneView in nextCell.subviews) {
                if ([oneView isMemberOfClass:[UITextField class]]) {
                    nextField = (UITextField *)oneView;
                }
            }
            [nextField becomeFirstResponder];
            [self.tableView scrollToRowAtIndexPath:newPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        } else {
            [sender resignFirstResponder];
        }
    } else {
        [sender resignFirstResponder];
    }
    
}

- (IBAction)textFieldChanged:(id)sender
{
    switch (((UITextField*)sender).tag) {
        case AccountTagIndex:
            account = [(UITextField *)sender text];
            break;
        case PasswordTagIndex:
            password = [(UITextField *)sender text];
            break;
        case URLTagIndex:
            url = [(UITextField *)sender text];
            break;
        default:
            break;
    }
}

#pragma mark - SegmentedControl delegate

- (IBAction)segChanged:(id)sender
{
    mode = ((UISegmentedControl*)sender).selectedSegmentIndex;
}

@end

//
//  ZTCUserSettingsViewController.m
//  ZenTao Client
//
//  Created by Puttin Wong on 3/22/13.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//

#import <QuickDialog/QuickDialog.h>
#import "ZTCUserSettingsViewController.h"
#import "ZTCAPIClient.h"
#import "ZTCNotice.h"
#import "PDKeychainBindings.h"

@interface ZTCUserSettingsViewController ()

@end

@implementation ZTCUserSettingsViewController

- (id)init{
    self = [super init];
    if (self) {
        // Custom initialization
        self.root = [self create];
        self.resizeWhenKeyboardPresented = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(tryLogin)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (QRootElement*) create {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    QRootElement *root = [QRootElement new];
    root.title = NSLocalizedString(@"login", nil);
    root.grouped = YES;
    
    QSection *accountSection = [QSection new];
    accountSection.title = NSLocalizedString(@"login Basic Group", nil);
    accountSection.footer = NSLocalizedString(@"login Basic Group Desc", nil);
    QEntryElement *accountEntry = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"login Account", nil) Value:[defaults stringForKey:@"account"] Placeholder:@"demo"];
    accountEntry.key = @"account";
    accountEntry.autocorrectionType = UITextAutocorrectionTypeNo;
    accountEntry.enablesReturnKeyAutomatically = YES;
    accountEntry.keyboardType = UIKeyboardTypeASCIICapable;
    accountEntry.autocapitalizationType = UITextAutocapitalizationTypeNone;
//    accountEntry.appearance.valueAlignment = NSTextAlignmentLeft;
    QEntryElement *passwordEntry = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"login Password", nil) Value:[defaults stringForKey:@"password"] Placeholder:@"123456"];
    passwordEntry.key = @"password";
    passwordEntry.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordEntry.enablesReturnKeyAutomatically = YES;
    passwordEntry.keyboardType = UIKeyboardTypeASCIICapable;
    passwordEntry.secureTextEntry = YES;
    passwordEntry.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [accountSection addElement:accountEntry];
    [accountSection addElement:passwordEntry];
    
    QSection *urlSection = [QSection new];
    urlSection.title = NSLocalizedString(@"login URL Group", nil);
    urlSection.footer = NSLocalizedString(@"login URL Group Desc", nil);
    QEntryElement *urlEntry = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"login URL", nil) Value:[defaults stringForKey:@"url"] Placeholder:@"demo.zentao.net"];
    urlEntry.key = @"url";
    urlEntry.autocorrectionType = UITextAutocorrectionTypeNo;
    urlEntry.enablesReturnKeyAutomatically = YES;
    urlEntry.keyboardType = UIKeyboardTypeASCIICapable;
    urlEntry.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [urlSection addElement:urlEntry];
    
    
    [root addSection:accountSection];
    [root addSection:urlSection];
    
    return root;
}

#pragma mark - login

- (void)tryLogin
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem.enabled = NO;
        });
        NSString *account = ((QEntryElement*)[self.root elementWithKey:@"account"]).textValue;
        NSString *password = ((QEntryElement*)[self.root elementWithKey:@"password"]).textValue;
        NSString *url = ((QEntryElement*)[self.root elementWithKey:@"url"]).textValue;
        if ([ZTCAPIClient loginWithAccount:account Password:password BaseURL:url]) {
            PDKeychainBindings *bindings = [PDKeychainBindings sharedKeychainBindings];
            [bindings setObject:account forKey:kZTCKeychainAccount];
            [bindings setObject:password forKey:kZTCKeychainPassword];
            [bindings setObject:url forKey:kZTCKeychainUrl];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
                [ZTCAPIClient showMainView];
                [ZTCNotice showSuccessNoticeInView:[[[[UIApplication sharedApplication] delegate] window] rootViewController].view title:NSLocalizedString(@"login success title", nil)];
            });
        } else {
            //login fail;
            dispatch_async(dispatch_get_main_queue(), ^{
                [ZTCNotice showErrorNoticeInView:self.view title:NSLocalizedString(@"login fail title", nil) message:NSLocalizedString(@"login fail message", nil)];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem.enabled = YES;
        });
    });
}

#pragma mark - Rotate

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (IS_IPAD) {
        return YES;
    } else {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSInteger)supportedInterfaceOrientations{
    NSInteger mask = 0;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeRight])
        mask |= UIInterfaceOrientationMaskLandscapeRight;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeLeft])
        mask |= UIInterfaceOrientationMaskLandscapeLeft;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortrait])
        mask |= UIInterfaceOrientationMaskPortrait;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortraitUpsideDown])
        mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    return mask;
}

@end

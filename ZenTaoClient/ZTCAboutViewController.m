//
//  ZTCAboutViewController.m
//  ZenTao Client
//
//  Created by Puttin Wong on 05/19/2013.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//

#import "ZTCAboutViewController.h"
#import <QuickDialog/QuickDialog.h>
#import "IIViewDeckController.h"
#import <MessageUI/MessageUI.h>
#import <OpenUDID/OpenUDID.h>

@interface ZTCAboutViewController () <IIViewDeckControllerDelegate,MFMailComposeViewControllerDelegate>

@end

@implementation ZTCAboutViewController

- (id)init {
    self = [super init];
    if (self) {
        self.root = [self create];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //viewDeck
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(showMenu)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (QRootElement*) create {
    QRootElement *root = [[QRootElement alloc] init];
    root.title = NSLocalizedString(@"About", @"About page title");
    root.grouped = YES;
    
    QSection *sectionApp = [[QSection alloc] init];
    sectionApp.title = NSLocalizedString(@"About App", @"About App section title");
    QLabelElement *versionLabel = [[QLabelElement alloc] initWithTitle:NSLocalizedString(@"About Version", @"About version label") Value:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    QLabelElement *feedbackButtonElement = [[QLabelElement alloc] initWithTitle:NSLocalizedString(@"About Feedback", @"About Feedback button title") Value:nil];
//    feedbackButtonElement.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    feedbackButtonElement.controllerAction = @"onFeedback";
    QWebElement *changelogWebElement = [[QWebElement alloc] initWithTitle:NSLocalizedString(@"About Changelog", @"App Changelog") url:@"https://github.com/puttin/ZenTao-Client/raw/master/CHANGELOG.md"];
    QWebElement *disclaimerWebElement = [[QWebElement alloc] initWithTitle:NSLocalizedString(@"About Disclaimer", @"App Changelog") url:@"https://github.com/puttin/ZenTao-Client/raw/develop/DISCLAIMER.md"];
    [sectionApp addElement:versionLabel];
    [sectionApp addElement:feedbackButtonElement];
    [sectionApp addElement:changelogWebElement];
    [sectionApp addElement:disclaimerWebElement];
    
    QSection *sectionThank = [[QSection alloc] init];
    sectionThank.title = NSLocalizedString(@"About Blank", @"About Thank section title");
    [sectionThank addElement:[[QRootElement alloc] initWithJSONFile:@"aboutThanks"]];
    
    QSection *sectionMe = [[QSection alloc] init];
    sectionMe.title = NSLocalizedString(@"About Blank", @"About Me section title");
    QLabelElement *aboutMeLabelElement = [[QLabelElement alloc] initWithTitle:NSLocalizedString(@"About Me", @"About Me") Value:nil];
    aboutMeLabelElement.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    aboutMeLabelElement.onSelected = ^() {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://about.me/Puttin"]];
    };
    [sectionMe addElement:aboutMeLabelElement];
//    QWebElement *aboutMeWebElement = [[QWebElement alloc] initWithTitle:NSLocalizedString(@"About Me", @"About Me") url:@"http://about.me/Puttin"];
//    [sectionMe addElement:aboutMeWebElement];
    
    [root addSection:sectionApp];
    [root addSection:sectionThank];
    [root addSection:sectionMe];
    
    return root;
}

- (void) onFeedback {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        [mailComposer setSubject:[NSString stringWithFormat:@"%@ - %@ - #feedback",NSLocalizedString(@"About Feedback Mail Title", "About Feedback Mail Title"),[OpenUDID value]]];
        [mailComposer setToRecipients:@[@"zentao.client@gmail.com"]];
//        // Attach log file
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//                                                             NSUserDomainMask, YES);
//        NSString *documentsPath = [paths objectAtIndex:0];
//        NSString *stderrPath = [documentsPath stringByAppendingPathComponent:@"stderr.log"];
//        NSData *data = [NSData dataWithContentsOfFile:stderrPath];
//        [mailComposer addAttachmentData:data mimeType:@"Text/XML" fileName:@"stderr.log"];
        UIDevice *device = [UIDevice currentDevice];
        NSString *emailBody =
        [NSString stringWithFormat:@"%@: %@\n%@, %@ %@\n%@",NSLocalizedString(@"About Feedback Mail App Version", @"About Feedback Mail App Version"),[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [device name], [device systemName], [device systemVersion],NSLocalizedString(@"About Feedback DO NOT MODIFY", @"tell user not modify mail content and title")];
        [mailComposer setMessageBody:emailBody isHTML:NO];
        [self presentViewController:mailComposer animated:YES
                         completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail send canceled...");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved...");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent...");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail send errored: %@...", [error localizedDescription]);
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ViewDeck & its delegate

- (void)viewDeckController:(IIViewDeckController *)viewDeckController willOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    [(IIViewDeckController*)self.viewDeckController.leftController openLeftView];
}

- (void)viewDeckController:(IIViewDeckController*)viewDeckController willCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    [(IIViewDeckController*)self.viewDeckController.leftController closeLeftView];
}

- (void) showMenu {
    [self.viewDeckController toggleLeftView];
}

@end

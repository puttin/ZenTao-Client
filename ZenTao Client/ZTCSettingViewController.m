//
//  ZTCSettingBasicViewController.m
//  ZenTao Client
//
//  Created by Puttin Wong on 05/06/2013.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//

#import "ZTCSettingViewController.h"

#ifdef USES_IASK_STATIC_LIBRARY
    #import "InAppSettingsKit/IASKSettingsReader.h"
#else
    #import "IASKSettingsReader.h"
#endif

#import "IASKSpecifier.h"
#import "IIViewDeckController.h"
#import "ZTCAPIClient.h"

@interface ZTCSettingViewController () <IIViewDeckControllerDelegate>

@end

@implementation ZTCSettingViewController

- (id)init {
    self = [super init];
    if (self) {
        self.delegate = self;
        self.showDoneButton = NO;
        self.title = NSLocalizedString(@"setting", nil);
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

#pragma mark -
#pragma mark IASKAppSettingsViewControllerDelegate protocol
- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
//    [self dismissModalViewControllerAnimated:YES];
	
	// your code here to reconfigure the app for changed settings
}

- (void)settingsViewController:(IASKAppSettingsViewController*)sender buttonTappedForSpecifier:(IASKSpecifier*)specifier {
	if ([specifier.key isEqualToString:@"ButtonLogin"]) {
        [ZTCAPIClient logout];
        [ZTCAPIClient showLoginView:YES];
	} else {
	}
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

//
//  ZTCSettingBasicViewController.h
//  ZenTao Client
//
//  Created by Puttin Wong on 05/06/2013.
//  Copyright (c) 2013 Puttin Wong. All rights reserved.
//

#if USES_IASK_STATIC_LIBRARY
    #import "InAppSettingsKit/IASKAppSettingsViewController.h"
#else
    #import "IASKAppSettingsViewController.h"
#endif

@interface ZTCSettingViewController : IASKAppSettingsViewController <IASKSettingsDelegate> {
}

@end

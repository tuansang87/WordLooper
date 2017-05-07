/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>
#import <GTLR/OIDAuthorizationService.h>
#import "UtilsView.h"

#define kClientId  @"665124887696-ed9m78r2f786dpubqgsuoul728hac9v8.apps.googleusercontent.com"
#define kClientSecret  @"IXInCCghSLe63OMRar6PuSyU"
#define kSuccessURLString  @"wordlooper://"
#define kWordLooperFileID  @"0B6OTgkf6NJ0jTm5EWWlKOGRrRGM"
#define GOOLDE_RIDIRECT_SCHEME @"com.googleusercontent.apps.665124887696-ed9m78r2f786dpubqgsuoul728hac9v8:/oauthredirect"
#define kLocalGoogleDriveCachedFilePath  [NSString stringWithFormat : @"%@/%@" ,[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] ,@"wordlooper.json"]


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, nullable) id<OIDAuthorizationFlowSession> currentAuthorizationFlow;
@property (nonatomic, strong) UtilsView *utils;
@end

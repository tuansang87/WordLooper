/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AppDelegate.h"

#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import "DriveUtils.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  
  NSURL *jsCodeLocation;
  
  jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index.ios" fallbackResource:nil];
  
  RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                      moduleName:@"WordLooper"
                                               initialProperties:nil
                                                   launchOptions:launchOptions];
  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];
  
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  
  [[DriveUtils sharedDrive] configClientId:kClientId
                              clientSecret:kClientSecret
                                    fileId:kWordLooperFileID
                             successString:kSuccessURLString];
  
  UIViewController *rctViewController = [UIViewController new];
  rctViewController.view = rootView;
  
  
//  UINavigationController *rootViewController = [[UINavigationController alloc]
//                                                initWithRootViewController:rctViewController];
  
  self.window.rootViewController = rctViewController;
  [self.window makeKeyAndVisible];
  
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUtilsView:) name:@"kUtilsObject" object:nil];
  
  return YES;
}
-(void) setUtilsView:(NSNotification*) noti {
  if(noti && noti.object) {
    self.utils = (UtilsView*) (noti.object);
    if( [[DriveUtils sharedDrive] isSignedIn] == NO) {
      
      
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //        UIViewController *signInController = [[DriveUtils sharedDrive] runSigninThenHandler:^{
        //          [self dowloadLoadFile];
        //        }];
        //        UINavigationController *ctrl = (UINavigationController*)self.window.rootViewController;
        //        [ctrl pushViewController:signInController animated:NO];
        
        
        [[DriveUtils sharedDrive] runSigninWithPresentController:self.window.rootViewController thenHandler:^{
          [self dowloadLoadFile];
        }];
        
      });
      
    } else {
      [self dowloadLoadFile];
    }
  }
}

-(void) dowloadLoadFile {
  
  
  [[DriveUtils sharedDrive] downloadFile:kWordLooperFileID destinationURL:[NSURL fileURLWithPath:kLocalGoogleDriveCachedFilePath] withHandler:^(NSData *data) {
    // handle here
    if(data) {
      NSLog(@"%@ kLocalGoogleDriveCachedFilePath : " , kLocalGoogleDriveCachedFilePath);
      [data writeToFile:kLocalGoogleDriveCachedFilePath atomically:YES];
      id obj = [NSJSONSerialization JSONObjectWithData:data options:(0) error:nil];
      if(obj) {
        self.utils.onLoadCachedWordsCallback(obj);
        NSLog(@"drive %@" , obj);
      }
    }
  }];
}


-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
  // Sends the URL to the current authorization flow (if any) which will
  // process it if it relates to an authorization response.
  if ([_currentAuthorizationFlow resumeAuthorizationFlowWithURL:url]) {
    _currentAuthorizationFlow = nil;
    return YES;
  }
  
  // Your additional URL handling (if any) goes here.
  
  return NO;
}

@end

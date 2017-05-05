//
//  LoginViewManager.m
//  LoginView
//
//  Created by Sang Huynh on 7/18/16.
//  Copyright © 2016 Groupsurfing inc. All rights reserved.
//

#import "UtilViewManager.h"
#import "RCTBridge.h"
#import "RCTUIManager.h"
#import "UtilView.h"

@interface UtilViewManager()

@end

@implementation UtilViewManager
RCT_EXPORT_MODULE()
RCT_EXPORT_VIEW_PROPERTY(onSignInBtnClick, RCTDirectEventBlock)
- (RCTView *)view
{
    LoginView *mLoginView = [LoginView new]; 
    return mLoginView;
}

 

RCT_EXPORT_METHOD(showErrorMessage:(nonnull NSNumber *)reactTag
                  value:(NSString*)messageKey)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, LoginView*> *viewRegistry) {
        LoginView * view = viewRegistry[reactTag];
        if (![view isKindOfClass:[LoginView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting LoginView, got: %@", view);
        } else {
            [view showErrorMessage:messageKey];
        }
    }];
}

@end

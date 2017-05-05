//
//  LoginViewManager.m
//  LoginView
//
//  Created by Sang Huynh on 7/18/16.
//  Copyright © 2016 Groupsurfing inc. All rights reserved.
//

#import "UtilsViewManager.h"
#import <React/RCTBridge.h>
#import <React/RCTUIManager.h>
#import "UtilsView.h"

@interface UtilsViewManager()

@end

@implementation UtilsViewManager
RCT_EXPORT_MODULE()
- (RCTView *)view
{
    UtilsView *mUtilsView = [UtilsView new];
    return mUtilsView;
}


RCT_EXPORT_VIEW_PROPERTY(onAudioLinkDetectedCallback, RCTDirectEventBlock)

 

RCT_EXPORT_METHOD(fecthAudioLinkForWord:(nonnull NSString*) word fourcePlay:(BOOL) shouldForce withReactTag:(nonnull NSNumber *)reactTag)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UtilsView*> *viewRegistry) {
        UtilsView * view = viewRegistry[reactTag];
        if (![view isKindOfClass:[UtilsView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting UtilsView, got: %@", view);
        } else {
            [view fecthAudioLinkForWord:word fourcePlay:(BOOL) shouldForce withCallback:nil];
        }
    }];
}


RCT_EXPORT_METHOD(playSound:(nonnull NSString*) soundUrl withReactTag:(nonnull NSNumber *)reactTag)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UtilsView*> *viewRegistry) {
        UtilsView * view = viewRegistry[reactTag];
        if (![view isKindOfClass:[UtilsView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting UtilsView, got: %@", view);
        } else {
            [view playSound:soundUrl];
        }
    }];
}

@end

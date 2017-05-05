//
//  LoginView.h
//  LoginView
//
//  Created by Sang Huynh on 7/18/16.
//  Copyright © 2016 Groupsurfing inc. All rights reserved.
//


#import <React/RCTView.h>



@interface UtilsView : RCTView
@property(nonatomic , copy) RCTDirectEventBlock _Nonnull onAudioLinkDetectedCallback;
-(void) fecthAudioLinkForWord:(nonnull NSString*) word fourcePlay:(BOOL) shouldForce withCallback:(RCTDirectEventBlock _Nullable ) callback;
-(void) playSound:(nonnull NSString*) soundUrl;
@end

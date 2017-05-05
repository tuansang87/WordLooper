//
//  UtilView.m
//  UtilView
//
//  Created by Sang Huynh on 7/18/16.
//  Copyright © 2016 Groupsurfing inc. All rights reserved.
//
#import "UtilView.h"



@interface UtilView() {
    
}

@end

@implementation UtilView

-(void) dealloc {
 
}


- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
      self.hidden = YES;
    }
    return self;
}

-(void) layoutSubviews {
    [super layoutSubviews];
    CGRect rect = self.superview.bounds;
    self.frame = rect;
    
}


-(void) showErrorMessage:(NSString*) msgKey{
    [self.loginView showErrorMessage:BC_NSLocalizedString(msgKey, EMPTY_STR)];
}

-(void) showResetMesssageSuccess{
    [self.loginView showResetMesssageSuccess];
}

-(void) showUnconfirmEmailForm{
    [self.loginView showUnconfirmEmailForm];
}

@end

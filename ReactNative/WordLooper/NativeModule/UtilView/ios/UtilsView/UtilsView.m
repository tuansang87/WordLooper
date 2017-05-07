//
//  UtilView.m
//  UtilView
//
//  Created by Sang Huynh on 7/18/16.
//  Copyright © 2016 Groupsurfing inc. All rights reserved.
//
#import "UtilsView.h"

#import <AVFoundation/AVFoundation.h>

@interface UtilsView() {
    AVAudioPlayer *player;
   
}
@property(strong , nonatomic)  NSString *lastPlayWord;
@end

@implementation UtilsView

-(void) dealloc {
    self.onAudioLinkDetectedCallback = nil;
    self.onLoadCachedWordsCallback = nil;
}
- (instancetype)init
{
    if ((self = [super init])) {
        self.hidden = YES;
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
      self.hidden = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kUtilsObject" object:self];
    }
    return self;
}

//-(void) fecthAudioLinkForWord:(nonnull NSString*) word withCallback:(RCTDirectEventBlock) callback{
//    // do nothing
//}

@end

@interface UtilsView (AudioFinding)
@end

@implementation  UtilsView (AudioFinding)

-(void) downloadAndPlay:(NSString*)soundUrl {
    NSURL *url = [NSURL URLWithString:soundUrl];
    if (url != nil) {
        NSData * data = [NSData dataWithContentsOfURL:url];
        __weak typeof(self) weakSelf = self;
        dispatch_async( dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf ;
            if(!strongSelf) return;
            NSError *error;
            strongSelf->player = [[AVAudioPlayer alloc] initWithData:data error:&error];
            if(!error && strongSelf->player) {
                [strongSelf->player prepareToPlay];
                [strongSelf->player play];
            }
        });
        
        
    }
}

-(void) playSound:(NSString*) soundUrl{
    [self performSelectorInBackground:@selector(downloadAndPlay:) withObject:soundUrl];
}

-(NSString*) getAutioFileFromSource:(NSString*) src {
        NSString *contentUrlStr = @"<source src=";
    NSInteger beginPos = 0;
    NSInteger srcLength = src.length;
    
    NSInteger searchLength = srcLength - beginPos;
        while (beginPos < srcLength) {
            NSRange contentUrlRange =  [src rangeOfString:contentUrlStr options:NSCaseInsensitiveSearch range:NSMakeRange(beginPos, searchLength)];
            
            if (contentUrlRange.location != NSNotFound){
                NSString *doubleQuoteStr = @"\"";
                NSInteger newPos = contentUrlRange.location + contentUrlRange.length;
                NSInteger rangeLength = src.length - newPos;
                
                NSRange doubleQuoteRange = [src rangeOfString:doubleQuoteStr options:NSCaseInsensitiveSearch range:NSMakeRange(newPos, rangeLength)];
 
                if (doubleQuoteRange.location != NSNotFound) {
                    
                    NSInteger newPos = doubleQuoteRange.location + doubleQuoteRange.length;
                    NSInteger rangeLength = src.length - newPos;
                    
                    NSRange endDoubleQuoteRange =[src rangeOfString:doubleQuoteStr options:NSCaseInsensitiveSearch range:NSMakeRange(newPos, rangeLength)];
               
                    if (endDoubleQuoteRange.location != NSNotFound ){
                        NSString * link = [src substringWithRange:NSMakeRange(newPos, endDoubleQuoteRange.location - newPos)];
                        NSLog(@"%@" , link);
                        if([link containsString:@"mp3"]) {
                            return link;
                        }
                        
                        beginPos = endDoubleQuoteRange.location + 1;
                        searchLength = src.length - beginPos;
                    } else {
                        break;
                    }
                }
            }
        }
        
    return @"";
    }

-(void) fecthAudioLinkForWord:(nonnull NSString*) word fourcePlay:(BOOL) shouldForce withCallback:(RCTDirectEventBlock) callback{
    // handle here
    
    if(shouldForce) {
        self.lastPlayWord = nil;
    }
    if (self.lastPlayWord){
        if (self.lastPlayWord == word) {
            return;
        }
    }
    self.lastPlayWord = word;
    
    NSURLSession * session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSString *text  = [word lowercaseString];
    text = [text  stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.dictionary.com/browse/%@?s=t", text]]
                                            completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(!error && data) {
            NSString *returnData = nil;
            if ((returnData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding])) {
                NSString *link = [self getAutioFileFromSource:returnData];
                if(callback) {
                    callback(@{@"link" : link});
                }
                if(self.onAudioLinkDetectedCallback) {
                    self.onAudioLinkDetectedCallback(@{@"link" : link});
                }
            }
        }
    }];
 
    [dataTask resume];
 
}

-(void) downloadFileWithCallback:(RCTDirectEventBlock) callback{
    // handle here
    
    NSURLSession * session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
 
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:@"https://drive.google.com/file/d/0B6OTgkf6NJ0jTm5EWWlKOGRrRGM/view?usp=sharing"]
                                            completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                if(!error && data) {
                                                    NSString *returnData = nil;
                                                    if ((returnData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding])) {
                                                        
                                                    }
                                                }
                                            }];
    
    [dataTask resume];
    
}



@end

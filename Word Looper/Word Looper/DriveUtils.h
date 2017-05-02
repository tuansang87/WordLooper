/* Copyright (c) 2012 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  DriveSampleWindowController.h
//

// The sample app controllers are built with ARC, though the sources of
// the GTLR library should be built without ARC using the compiler flag
// -fno-objc-arc in the Compile Sources build phase of the application
// target.

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import <Cocoa/Cocoa.h>

#import "GTLRDrive.h"

@interface DriveUtils : NSObject {
  
}

+ (DriveUtils *)sharedDrive;
- (BOOL)isSignedIn;
- (void)configClientId:(NSString*)clientId
          clientSecret:(NSString*)clientSecret
                fileId:(NSString*) fileID
         successString:(NSString*) successString;
- (void)runSigninThenHandler:(void (^)(void))handler;

- (void)downloadFile:(NSString *)fileID  destinationURL:(NSURL*)destinationURL withHandler:(void (^)(NSData*))handler;
- (void)uploadFileAtPath:(NSString *)path;


@end

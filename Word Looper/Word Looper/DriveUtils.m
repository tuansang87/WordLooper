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
//  DriveSampleWindowController.m
//

#import "DriveUtils.h"

#import "GTLR/AppAuth.h"
#import "GTLR/GTLRUtilities.h"
#import "GTLR/GTMSessionFetcherService.h"
#import "GTLR/GTMSessionFetcherLogging.h"
#import "GTLR/GTMAppAuth.h"

// Segmented control indices.
enum {
    kRevisionsSegment = 0,
    kPermissionsSegment,
    kChildrenSegment,
    kParentsSegment
};

// This is the URL shown users after completing the OAuth flow. This is an information page only and
// is not part of the authorization protocol. You can replace it with any URL you like.
// We recommend at a minimum that the page displayed instructs users to return to the app.


@interface DriveUtils ()
@property (nonatomic, readonly) GTLRDriveService *driveService;
@end

@implementation DriveUtils {
    GTLRDrive_FileList *_fileList;
    GTLRServiceTicket *_fileListTicket;
    NSError *_fileListFetchError;
    GTLRServiceTicket *_editFileListTicket;
    GTLRServiceTicket *_uploadFileTicket;
    
    // Details
    GTLRDrive_RevisionList *_revisionList;
    NSError *_revisionListFetchError;
    
    GTLRDrive_PermissionList *_permissionList;
    NSError *_permissionListFetchError;
    
    GTLRDrive_FileList *_childList;
    NSError *_childListFetchError;
    
    NSArray *_parentsList;
    NSError *_parentsListFetchError;
    
    GTLRServiceTicket *_detailsTicket;
    NSError *_detailsFetchError;
    
    OIDRedirectHTTPHandler *_redirectHTTPHandler;
    
    NSString *_fileID;
     NSString *_clientID;
     NSString *_clientSecret;
     NSString *_sucessUrlString;
}

+ (DriveUtils *)sharedDrive {
    static DriveUtils* sharedDrive = nil;
    if (!sharedDrive) {
        sharedDrive = [[DriveUtils alloc] init];
    }
    return sharedDrive;
}


- (id)init {
    if (self = [super init]) {
        // Attempts to deserialize authorization from keychain in GTMAppAuth format.
        id<GTMFetcherAuthorizationProtocol> authorization =
        [GTMAppAuthFetcherAuthorization authorizationFromKeychainForName:kGTMAppAuthKeychainItemName];
        self.driveService.authorizer = authorization;
        
        
    }
    
    return self;
    
    
}

#pragma mark -

- (NSString *)signedInUsername {
    // Get the email address of the signed-in user.
    id<GTMFetcherAuthorizationProtocol> auth = self.driveService.authorizer;
    BOOL isSignedIn = auth.canAuthorize;
    if (isSignedIn) {
        return auth.userEmail;
    } else {
        return nil;
    }
}

- (BOOL)isSignedIn {
    NSString *name = [self signedInUsername];
    return (name != nil);
}

#pragma mark IBActions

- (void)downloadFile:(NSString *)fileID  destinationURL:(NSURL*)destinationURL  withHandler:(void (^)(NSData*))handler{
    GTLRDriveService *service = self.driveService;
    
    GTLRQuery *query;
    query = [GTLRDriveQuery_FilesGet queryForMediaWithFileId:fileID];
    
    [service executeQuery:query
        completionHandler:^(GTLRServiceTicket *callbackTicket,
                            GTLRDataObject *object,
                            NSError *callbackError) {
            
            if (callbackError == nil) {
                if(handler) {
                    handler(object.data);
                }
                
            }
            
        }];
}

- (NSString *)extensionForMIMEType:(NSString *)mimeType {
    // Try to convert a MIME type to an extension using the Mac's type identifiers.
    NSString *result = nil;
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType,
                                                            (__bridge CFStringRef)mimeType, NULL);
    if (uti) {
        CFStringRef cfExtn = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension);
        if (cfExtn) {
            result = CFBridgingRelease(cfExtn);
        }
        CFRelease(uti);
    }
    return result;
}


#pragma mark -

// Get a service object with the current username/password
//
// A "service" object handles networking tasks.  Service objects
// contain user authentication information as well as networking
// state information (such as cookies and the "last modified" date for
// fetched data.)

- (GTLRDriveService *)driveService {
    static GTLRDriveService *service;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[GTLRDriveService alloc] init];
        
        // Turn on the library's shouldFetchNextPages feature to ensure that all items
        // are fetched.  This applies to queries which return an object derived from
        // GTLRCollectionObject.
        service.shouldFetchNextPages = YES;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically
        service.retryEnabled = YES;
    });
    return service;
}

- (NSString *)descriptionForFileID:(NSString *)fileID {
    NSArray *files = _fileList.files;
    GTLRDrive_File *file = [GTLRUtilities firstObjectFromArray:files
                                                     withValue:fileID
                                                    forKeyPath:@"identifier"];
    if (file) {
        return file.name;
    } else {
        // Can't find the file by its identifier.
        return [NSString stringWithFormat:@"<%@>", fileID];
    }
}

- (NSString *)descriptionForDetailItem:(id)item {
    if ([item isKindOfClass:[GTLRDrive_Revision class]]) {
        return ((GTLRDrive_Revision *)item).modifiedTime.stringValue;
    } else if ([item isKindOfClass:[GTLRDrive_Permission class]]) {
        return ((GTLRDrive_Permission *)item).displayName;
    } else if ([item isKindOfClass:[GTLRDrive_File class]]) {
        NSString *fileID = ((GTLRDrive_File *)item).identifier;
        return [self descriptionForFileID:fileID];
    } else if ([item isKindOfClass:[NSString class]]) {
        // item is probably a file ID
        return [self descriptionForFileID:item];
    }
    return nil;
}

#pragma mark -
#pragma mark Fetch File List

- (void)fetchFileList {
    _fileList = nil;
    _fileListFetchError = nil;
    
    GTLRDriveService *service = self.driveService;
    
    GTLRDriveQuery_FilesList *query = [GTLRDriveQuery_FilesList query];
    
    // Because GTLRDrive_FileList is derived from GTLCollectionObject and the service
    // property shouldFetchNextPages is enabled, this may do multiple fetches to
    // retrieve all items in the file list.
    
    // Google APIs typically allow the fields returned to be limited by the "fields" property.
    // The Drive API uses the "fields" property differently by not sending most of the requested
    // resource's fields unless they are explicitly specified.
    query.fields = @"kind,nextPageToken,files(mimeType,id,kind,name,webViewLink,thumbnailLink,trashed)";
    
    _fileListTicket = [service executeQuery:query
                          completionHandler:^(GTLRServiceTicket *callbackTicket,
                                              GTLRDrive_FileList *fileList,
                                              NSError *callbackError) {
                              // Callback
                              _fileList = fileList;
                              _fileListFetchError = callbackError;
                              _fileListTicket = nil;
                              
                          }];
}

#pragma mark Uploading

- (void)uploadFileAtPath:(NSString *)path {
    NSURL *fileToUploadURL = [NSURL fileURLWithPath:path];
    NSError *fileError;
    if (![fileToUploadURL checkPromisedItemIsReachableAndReturnError:&fileError]) {
        // Could not read file data.
        return;
    }
    
    // Queries that support file uploads take an uploadParameters object.
    // The uploadParameters include the MIME type of the file being uploaded,
    // and either an NSData with the file contents, or a URL for
    // the file path.
    GTLRDriveService *service = self.driveService;
    
    NSString *filename = [path lastPathComponent];
    NSString *mimeType = [self MIMETypeFileName:filename
                                defaultMIMEType:@"binary/octet-stream"];
//    GTLRUploadParameters *uploadParameters = [GTLRUploadParameters uploadParametersWithFileURL:fileToUploadURL MIMEType:mimeType];
    GTLRUploadParameters *uploadParameters = [GTLRUploadParameters uploadParametersWithData:[NSData dataWithContentsOfFile:path] MIMEType:mimeType];

    GTLRDrive_File *updatedFile = [GTLRDrive_File object];
    updatedFile.name = filename;
    
    GTLRDriveQuery_FilesUpdate *query = [GTLRDriveQuery_FilesUpdate queryWithObject:updatedFile fileId:_fileID uploadParameters:uploadParameters];
    
    query.executionParameters.uploadProgressBlock = ^(GTLRServiceTicket *callbackTicket,
                                                      unsigned long long numberOfBytesRead,
                                                      unsigned long long dataLength) {
        
    };
 
    
    _uploadFileTicket = [service executeQuery:query
                            completionHandler:^(GTLRServiceTicket *callbackTicket,
                                                GTLRDrive_File *uploadedFile,
                                                NSError *callbackError) {
                                // Callback
                                _uploadFileTicket = nil;
                                if (callbackError == nil) {
                                    
                                } else {
                                    
                                }
                                
                            }];
    
}

- (NSString *)MIMETypeFileName:(NSString *)path
               defaultMIMEType:(NSString *)defaultType {
    NSString *result = defaultType;
    NSString *extension = [path pathExtension];
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                            (__bridge CFStringRef)extension, NULL);
    if (uti) {
        CFStringRef cfMIMEType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
        if (cfMIMEType) {
            result = CFBridgingRelease(cfMIMEType);
        }
        CFRelease(uti);
    }
    return result;
}

#pragma mark -
#pragma mark Sign In
static NSString *const kGTMAppAuthKeychainItemName = @"WordLooper.GTMAppAuth";
- (void)configClientId:(NSString*)clientId
                 clientSecret:(NSString*)clientSecret
                       fileId:(NSString*) fileID
                successString:(NSString*) successString{
    
    _clientID = [clientId copy];
    _clientSecret = [clientSecret copy];
    _sucessUrlString = [successString copy];
    _fileID = [fileID copy];
}

- (void)runSigninThenHandler:(void (^)(void))handler {

    
    NSURL *successURL = [NSURL URLWithString:_sucessUrlString];
    
    // Starts a loopback HTTP listener to receive the code, gets the redirect URI to be used.
    _redirectHTTPHandler = [[OIDRedirectHTTPHandler alloc] initWithSuccessURL:successURL];
    NSError *error;
    NSURL *localRedirectURI = [_redirectHTTPHandler startHTTPListener:&error];
    if (!localRedirectURI) {
        NSLog(@"Unexpected error starting redirect handler %@", error);
        return;
    }
    
    // Builds authentication request.
    OIDServiceConfiguration *configuration =
    [GTMAppAuthFetcherAuthorization configurationForGoogle];
    // Applications that only need to access files created by this app should
    // use the kGTLRAuthScopeDriveFile scope.
    NSArray<NSString *> *scopes = @[ kGTLRAuthScopeDrive, OIDScopeEmail ];
    OIDAuthorizationRequest *request =
    [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                  clientId:_clientID
                                              clientSecret:_clientSecret
                                                    scopes:scopes
                                               redirectURL:localRedirectURI
                                              responseType:OIDResponseTypeCode
                                      additionalParameters:nil];
    
    // performs authentication request
    __weak __typeof(self) weakSelf = self;
    _redirectHTTPHandler.currentAuthorizationFlow =
    [OIDAuthState authStateByPresentingAuthorizationRequest:request
                                                   callback:^(OIDAuthState *_Nullable authState,
                                                              NSError *_Nullable error) {
                                                       // Using weakSelf/strongSelf pattern to avoid retaining self as block execution is indeterminate
                                                       __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                       if (!strongSelf) {
                                                           return;
                                                       }
                                                       
                                                       // Brings this app to the foreground.
                                                       [[NSRunningApplication currentApplication]
                                                        activateWithOptions:(NSApplicationActivateAllWindows |
                                                                             NSApplicationActivateIgnoringOtherApps)];
                                                       
                                                       if (authState) {
                                                           // Creates a GTMAppAuthFetcherAuthorization object for authorizing requests.
                                                           GTMAppAuthFetcherAuthorization *gtmAuthorization =
                                                           [[GTMAppAuthFetcherAuthorization alloc] initWithAuthState:authState];
                                                           
                                                           // Sets the authorizer on the GTLRYouTubeService object so API calls will be authenticated.
                                                           strongSelf.driveService.authorizer = gtmAuthorization;
                                                           
                                                           // Serializes authorization to keychain in GTMAppAuth format.
                                                           [GTMAppAuthFetcherAuthorization saveAuthorization:gtmAuthorization
                                                                                           toKeychainForName:kGTMAppAuthKeychainItemName];
                                                           
                                                           // Executes post sign-in handler.
                                                           if (handler) handler();
                                                       } else {
                                                           strongSelf->_fileListFetchError = error;
                                                       }
                                                   }];
}

#pragma mark -
#pragma mark UI

#pragma mark Client ID Sheet


@end

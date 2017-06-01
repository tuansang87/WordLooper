//
//  Macro.swift
//  Word Looper
//
//  Created by Sang Huynh on 4/26/17.
//  Copyright © 2017 GKXIM. All rights reserved.
//

import Cocoa
let kSuccessURLString = "wordlooper://"
let kClientId = "665124887696-ed9m78r2f786dpubqgsuoul728hac9v8.apps.googleusercontent.com"
let kClientSecret = "IXInCCghSLe63OMRar6PuSyU"

#if TUYEN
    // For Tuyen
let kWordLooperFileID = "0B6OTgkf6NJ0jblcteGpEdmdvTzg"
let kLocalGoogleDriveCachedFolder = "\(NSHomeDirectory())/Documents/WordLooper/Tuyen/"
let kLocalGoogleDriveCachedFilePath =  kLocalGoogleDriveCachedFolder + "wordlooper.json"
#elseif SON
    // For Son
let kWordLooperFileID = "0B6OTgkf6NJ0jenB6MTFvYmQ0b0k"
let kLocalGoogleDriveCachedFolder = "\(NSHomeDirectory())/Documents/WordLooper/Son/"
let kLocalGoogleDriveCachedFilePath =  kLocalGoogleDriveCachedFolder + "wordlooper.json"
#else
    // For myself
let kWordLooperFileID = "0B6OTgkf6NJ0jTm5EWWlKOGRrRGM"
let kLocalGoogleDriveCachedFilePath = "\(NSHomeDirectory())/Sites/wordlooper.json"
#endif





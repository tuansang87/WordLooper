//
//  AppDelegate.swift
//  Word Looper
//
//  Created by Sang Huynh on 4/24/17.
//  Copyright © 2017 GKXIM. All rights reserved.
//

import Cocoa

@NSApplicationMain



class AppDelegate: NSObject, NSApplicationDelegate {
    
    
    static let kUserDict : String = "kUserDict"
    static let kUserDictWords : String = "words"
    static let kUserDictDate : String = "date"
    
    static let kLoopIndex : String = "kLoopIndex"
    static let kSearchMode : String = "kSearchMode"
    static let kLoopDirection : String = "kLoopDirection"
    
       
    
    public var currentLoopIdx = 0
    public var searchMode :SEARCH_MODE = .all
    public var words : [NSDictionary]? = nil
    public var loopDirection = true // 0|1 : go back|forward
    
    let kObjectAttributeIdKey = "word"
    
    
    func uniqueArray(arr: [AnyObject], attributeKey : String, irgnoreKeyValue : [Int]) -> [AnyObject] {
        let kIdKeyPath = "@distinctUnionOfObjects.\(kObjectAttributeIdKey)"
        
        var uniqueObjs : [AnyObject] = []
        let uniqueKeyVals = ((arr as NSArray).value(forKeyPath: kIdKeyPath) as? NSArray)!
        
        uniqueKeyVals.enumerateObjects({ (val, idx, stop) -> Void in
            let arrFilter = arr.filter({ (tmp) -> Bool in
                
                if let tmpValue = tmp.value(forKey: attributeKey) {
                    
                    return "\(tmpValue)" == "\(val)" && irgnoreKeyValue.filter({ (irgnoreValue) -> Bool in
                        return "\(irgnoreValue)" == "\(tmpValue)"
                    }).count == 0
                    
                } else {
                    stop.initialize(to: true)
                    return false
                }
                
            })
            
            if arrFilter.count > 0 {
                uniqueObjs.append(arrFilter.last!)
            }
        })
        return uniqueObjs
    }
    
    func addWord(word : String , imagePath: String? ,
                 own_definition : String? ,
                 audio : String?,
                 ignore : Bool
        ){
        if words != nil {
            let wordDict = NSMutableDictionary();
            if word.characters.count > 0 {
                wordDict["word"] = word.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()
            }
         
            wordDict["ignore"] = ignore
          
            if let audio = audio {
                if audio.characters.count > 0 {
                    wordDict["audio"] = audio
                }
            }
            
            
            if let imagePath = imagePath {
                if imagePath.characters.count > 0 {
                    wordDict["image"] = imagePath.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                }
                
            }
            if let own_definition = own_definition {
                if own_definition.characters.count > 0 {
                    wordDict["own_definition"] = own_definition.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                }
                
            }
            var cnt = -1;
            var isExisted = false;
            for tmp in self.words! {
                cnt += 1;
                if (tmp["word"] as! String) ==  (wordDict["word"] as! String) {
                    isExisted = true
                    break;
                }
                
            }
            if(isExisted) {
                self.words?.remove(at: cnt);
            } else {
                cnt = 0;
            }
            if(!ignore) {
                self.words?.insert(wordDict, at: cnt)
            } else {
                self.words?.append(wordDict)
            }
            
            
         
            let dict = [AppDelegate.kUserDictWords : self.words! , AppDelegate.kUserDictDate : NSDate().timeIntervalSince1970] as [String : Any]
            
            UserDefaults.standard.set(dict, forKey: AppDelegate.kUserDict)
            UserDefaults.standard.synchronize()
            do {
                let destinationURL = NSURL(fileURLWithPath: kLocalGoogleDriveCachedFilePath)
                let dataObject = try JSONSerialization.data(withJSONObject: dict, options: [])
                try dataObject.write(to: destinationURL as URL , options: Data.WritingOptions.atomic)
            } catch let error as NSError {
                print(error.description)
            }
            
        }
       
        

    }
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        do {
            #if TUYEN
                let boolPointer = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1);
                boolPointer.initialize(to: true);
                
                let fileManager = FileManager.default;
                if !fileManager.fileExists(atPath: kLocalGoogleDriveCachedFolder, isDirectory:boolPointer) {
                    let url = URL(fileURLWithPath: kLocalGoogleDriveCachedFolder);
                    do {
                        try fileManager.createDirectory(at:url , withIntermediateDirectories: true, attributes: nil)
                    } catch let err as NSError {
                        print(err);
                    }
                }
            #elseif SON
                let boolPointer = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1);
                boolPointer.initialize(to: true);
                
                let fileManager = FileManager.default;
                if !fileManager.fileExists(atPath: kLocalGoogleDriveCachedFolder, isDirectory:boolPointer) {
                    let url = URL(fileURLWithPath: kLocalGoogleDriveCachedFolder);
                    do {
                        try fileManager.createDirectory(at:url , withIntermediateDirectories: true, attributes: nil)
                    } catch let err as NSError {
                        print(err);
                    }
                }
            #endif
            
            // Insert code here to initialize your application
            if let tmp = UserDefaults.standard.object(forKey: AppDelegate.kUserDict) as? NSDictionary {
                if let words = tmp[AppDelegate.kUserDictWords] as? [NSDictionary] {
                    let inAppInterval = tmp[AppDelegate.kUserDictDate] as! Double
                    
                    let data = NSData(contentsOfFile: kLocalGoogleDriveCachedFilePath)
                    if data != nil
                    {
                        if let jsonObject = try JSONSerialization.jsonObject(with: data! as Data, options: []) as? NSDictionary {
                            let timeInterval = jsonObject[AppDelegate.kUserDictDate] as! Double
                            
                            if(timeInterval > inAppInterval) {
                                if let words = jsonObject[AppDelegate.kUserDictWords] as? [NSDictionary] {
                                    self.words = NSMutableArray(array: words) as? [NSDictionary]
                                } else {
                                    self.words = NSMutableArray(array: words) as? [NSDictionary]
                                }
                                
                            } else {
                                self.words = NSMutableArray(array: words) as? [NSDictionary]
                            }
                        } else {
                            self.words = NSMutableArray(array: words) as? [NSDictionary]
                        }
                        
                    } else {
                        self.words = NSMutableArray(array: words) as? [NSDictionary]
                    }
                } else {
                    self.words = []
                }
                
                
                
            } else {
                self.words = []
            }
            
            
            
        } catch let error as NSError {
            print(error.description)
        }
        
       
        
        if let tmp = UserDefaults.standard.object(forKey: AppDelegate.kLoopIndex) as? Int {
            self.currentLoopIdx = tmp
        } else {
            self.currentLoopIdx = 0
        }
        
        if let tmp = UserDefaults.standard.object(forKey: AppDelegate.kSearchMode) as? String {
            if tmp == SEARCH_MODE.all.rawValue {
                 self.searchMode = .all
            } else if tmp == SEARCH_MODE.new.rawValue {
                self.searchMode = .new
            }else if tmp == SEARCH_MODE.image.rawValue {
                self.searchMode = .image
            }
        } else {
            self.searchMode = .all
        }
        
        if let tmp = UserDefaults.standard.object(forKey: AppDelegate.kLoopDirection) as? Bool {
            self.loopDirection = tmp
        } else {
            self.loopDirection = true
        }
        if let window = NSApp.mainWindow {
            window.minSize = CGSize(width: 375, height: (NSScreen.main!.frame.size.height))
            window.maxSize = CGSize(width: 1000, height: NSScreen.main!.frame.size.height)
            window.setFrame(CGRect(x: 30, y: 0, width: 375, height: (NSScreen.main!.frame.size.height)), display: true)
        }
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        UserDefaults.standard.set(currentLoopIdx, forKey: AppDelegate.kLoopIndex)
        UserDefaults.standard.set(searchMode.rawValue, forKey: AppDelegate.kSearchMode)
        UserDefaults.standard.set(loopDirection, forKey: AppDelegate.kLoopDirection)
        UserDefaults.standard.synchronize()
        
        let dict = [AppDelegate.kUserDictWords : self.words! , AppDelegate.kUserDictDate : NSDate().timeIntervalSince1970] as [String : Any]
        
        UserDefaults.standard.set(dict, forKey: AppDelegate.kUserDict)
        UserDefaults.standard.synchronize()
        do {
            let destinationURL = NSURL(fileURLWithPath: kLocalGoogleDriveCachedFilePath)
            let dataObject = try JSONSerialization.data(withJSONObject: dict, options: [])
            try dataObject.write(to: destinationURL as URL , options: Data.WritingOptions.atomic)
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    
    public func menuHasKeyEquivalent(_ menu: NSMenu, for event: NSEvent, target: AutoreleasingUnsafeMutablePointer<AnyObject?>?, action: UnsafeMutablePointer<Selector?>?) -> Bool {
        
        return true
    }
 
    class func handleHotkey(with event: NSEvent) {
        let keycode = event.keyCode
        
        if(keycode == HOTKEYCODE_QUICK_RESET) {
            // handleh here
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: HOTKEYCODE_QUICK_COMMAND_NOTI), object: kHotKeyReset)
        } else if(keycode == HOTKEYCODE_QUICK_GO_NEXT) {
            // handleh here
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: HOTKEYCODE_QUICK_COMMAND_NOTI), object: kGoNextWord)
        } else if(keycode == HOTKEYCODE_QUICK_GO_BACK) {
            // handleh here
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: HOTKEYCODE_QUICK_COMMAND_NOTI), object: kGoPreviousWord)
        } else if(keycode == HOTKEYCODE_QUICK_AUDIO) {
            // handleh here
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: HOTKEYCODE_QUICK_COMMAND_NOTI), object: kPlayCurrentWord)
        } else if(keycode == HOTKEYCODE_QUICK_GO_CACHED_WORDS) {
            // handleh here
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: HOTKEYCODE_QUICK_COMMAND_NOTI), object: kOpenCachedWords)
        } else if(keycode == HOTKEYCODE_QUICK_SAVE_WORD) {
            // handleh here
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: HOTKEYCODE_QUICK_COMMAND_NOTI), object: kSaveWord)
        } else if(keycode == HOTKEYCODE_QUICK_HOME) {
            // handleh here
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: HOTKEYCODE_QUICK_COMMAND_NOTI), object: kOpenHome)
        } else if(keycode == HOTKEYCODE_QUICK_LOOP) {
            // handleh here
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: HOTKEYCODE_QUICK_COMMAND_NOTI), object: kLoop)
        } else if(keycode == HOTKEYCODE_QUICK_LOOKUP_IN_ENGLISH) {
            // handleh here
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: HOTKEYCODE_QUICK_COMMAND_NOTI), object: kLookUpInEnglish)
        } else if(keycode == HOTKEYCODE_QUICK_LOOKUP_IN_VIETNAMESE) {
            // handleh here
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: HOTKEYCODE_QUICK_COMMAND_NOTI), object: kLookUpInVietnamese)
        }
            
        else if(keycode == HOTKEYCODE_QUICK_KILL_APP) {
            // handleh here
            exit(1);
        }
    }
}

var HOTKEYCODE_QUICK_COMMAND_NOTI = "HOTKEYCODE_QUICK_COMMAND_NOTI"
var kHotKeyReset = "kHotKeyReset"
var kGoNextWord = "kGoNextWord"
var kGoPreviousWord = "kGoPreviousWord"
var kPlayCurrentWord = "kPlayCurrentWord"
var kOpenCachedWords = "kOpenCachedWords"

var kLookUpInEnglish = "kLookUpInEnglish"
var kLookUpInVietnamese = "kLookUpInVietnamese"

var kSaveWord = "kSaveWord"
var kOpenHome = "kOpenHome"
var kLoop = "kLoop"

var HOTKEYCODE_QUICK_HOME = UInt16(4) ; //ctrl + H
var HOTKEYCODE_QUICK_SAVE_WORD =  UInt16(1) ; //ctrl + S
var HOTKEYCODE_QUICK_RESET = UInt16(15) ; //ctrl + R
var HOTKEYCODE_QUICK_GO_NEXT =  UInt16(47); //ctrl + >
var HOTKEYCODE_QUICK_GO_BACK = UInt16( 43); //ctrl + <

var HOTKEYCODE_QUICK_LOOKUP_IN_ENGLISH = UInt16(14) ; //ctrl + E
var HOTKEYCODE_QUICK_LOOKUP_IN_VIETNAMESE = UInt16(9) ; //ctrl + V

var HOTKEYCODE_QUICK_AUDIO =  UInt16(0); //ctrl+A
var HOTKEYCODE_QUICK_GO_CACHED_WORDS = UInt16( 8); //ctrl + C
var HOTKEYCODE_QUICK_LOOP = UInt16(37); //ctrl + L
var HOTKEYCODE_QUICK_KILL_APP =  UInt16(12); //cmd+Q

class CustomWindow: NSWindow {
    override func keyDown(with event: NSEvent) {
        AppDelegate.handleHotkey(with: event);
    }
}


enum SEARCH_MODE : String {
    case all = "all"
    case image = "image"
    case new = "new"
}

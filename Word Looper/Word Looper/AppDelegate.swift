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
    
    func addWord(word : String , imagePath: String? , own_definition : String? , audio : String?){
        if words != nil {
            let wordDict = NSMutableDictionary();
            if word.characters.count > 0 {
                wordDict["word"] = word.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()
            }
         
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
            for tmp in self.words! {
                cnt += 1;
                if (tmp["word"] as! String) ==  (wordDict["word"] as! String) {
                    break;
                }
            }
            if(cnt > 0) {
                self.words?.remove(at: cnt);
                self.words?.insert(wordDict, at: cnt)
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
            window.minSize = CGSize(width: 375, height: (NSScreen.main()!.frame.size.height))
            window.maxSize = CGSize(width: 1000, height: NSScreen.main()!.frame.size.height)
            window.setFrame(CGRect(x: 30, y: 0, width: 375, height: (NSScreen.main()!.frame.size.height)), display: true)
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
  
}


var kOpenMenu = "kOpenMenu"
var kOpenProfile = "kOpenProfile"
var kOpenSetting = "kOpenSetting"
var kOpenMyHexseeBrowser = "kOpenMyHexseeBrowser"
var kOpenHome = "kOpenHome"
var kOpenUserFriends = "kOpenUserFriends"
var kOPenPinFeeds = "kOPenPinFeeds"
var kSignOut = "kSignOut"
var kZoomIn = "kZoomIn"
var kZoomOut = "kZoomOut"
var kZoomReset = "kZoomReset"

var HOTKEYCODE_QUICK_MENU = UInt16(46) ; //cmd+M
var  HOTKEYCODE_QUICK_SETTING = UInt16(43);//cmd+,
var  HOTKEYCODE_QUICK_PROFILE =  UInt16(35); //cmd+P
var  HOTKEYCODE_QUICK_LAST_VISITED_PAGE_CHANNEL =  UInt16(37); //cmd+L
var  HOTKEYCODE_QUICK_HOME =  UInt16(4); //cmd+H
var  HOTKEYCODE_QUICK_FRIENDS_LIST = UInt16( 32); //cmd+U
var  HOTKEYCODE_QUICK_FEEDS =  UInt16(3); //cmd+F
var  HOTKEYCODE_QUICK_SIGN_OUT =  UInt16(1); //cmd+S
var  HOTKEYCODE_QUICK_KILL_APP =  UInt16(12); //cmd+Q

var  HOTKEYCODE_QUICK_ZOOM_IN =  UInt16(24); //cmd +
var  HOTKEYCODE_QUICK_ZOOM_OUT =  UInt16(27); //cmd +
var  HOTKEYCODE_QUICK_RESET_ZOOM =  UInt16(29); //cmd + 0

class CustomWindow: NSWindow {
    override func keyDown(with event: NSEvent) {
 
        let keycode = event.keyCode
        
        if(keycode == HOTKEYCODE_QUICK_MENU) {
            // handleh here
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kOpenMenu), object: nil)
        } else if(keycode == HOTKEYCODE_QUICK_PROFILE) {
            // handleh here
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kOpenProfile), object: nil)
        } else if(keycode == HOTKEYCODE_QUICK_SETTING) {
            // handleh here
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kOpenSetting), object: nil)
        } else if(keycode == HOTKEYCODE_QUICK_LAST_VISITED_PAGE_CHANNEL) {
            // handleh here
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kOpenMyHexseeBrowser), object: nil)
        } else if(keycode == HOTKEYCODE_QUICK_HOME) {
            // handleh here
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kOpenHome), object: nil)
        } else if(keycode == HOTKEYCODE_QUICK_FRIENDS_LIST) {
            // handleh here
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kOpenUserFriends), object: nil)
        } else if(keycode == HOTKEYCODE_QUICK_FEEDS) {
            // handleh here
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kOPenPinFeeds), object: nil)
        } else if(keycode == HOTKEYCODE_QUICK_SIGN_OUT) {
            // handleh here
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kSignOut), object: nil)
        } else if(keycode == HOTKEYCODE_QUICK_KILL_APP) {
            // handleh here
            exit(1);
        }
  
        else if(keycode == HOTKEYCODE_QUICK_ZOOM_IN) {
            // handleh here
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kZoomIn), object: nil)
        } else if(keycode == HOTKEYCODE_QUICK_ZOOM_OUT) {
            // handleh here
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kZoomOut), object: nil)
        } else if(keycode == HOTKEYCODE_QUICK_RESET_ZOOM) {
            // handleh here
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kZoomReset), object: nil)
        }
        
    }
}


enum SEARCH_MODE : String {
    case all = "all"
    case image = "image"
    case new = "new"
}

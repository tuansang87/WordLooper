//
//  CachedWordViewCell.swift
//  Word Looper
//
//  Created by Sang Huynh on 4/25/17.
//  Copyright © 2017 GKXIM. All rights reserved.
//

import Cocoa

typealias CallBackClosure = (Dictionary<String, Any>) -> Void
class CachedWordViewCell: NSView {

    @IBOutlet weak var lblWord: NSTextField!
   @IBOutlet weak var btnIgnore: NSButton!
    
    var mTag :Int = 0
    var mWord : Dictionary<String , Any>? = nil
    var deleteWordCallback: CallBackClosure? = nil
    var loadWordCallback: CallBackClosure? = nil
    var ignoreCallBack: CallBackClosure? = nil
    
    func setUpView(data : Dictionary<String , Any> ,
                   tag : Int,
                   loadWordCallback : @escaping CallBackClosure ,
                   deleteWordCallback : @escaping CallBackClosure,
                   ignoreCallBack : @escaping CallBackClosure
                   ) {
        self.mTag = tag
        self.mWord = data
        self.deleteWordCallback = deleteWordCallback
        self.loadWordCallback = loadWordCallback
        self.ignoreCallBack = ignoreCallBack
        
        if let text = self.mWord?["word"] as? String{
            self.lblWord.stringValue = text
        }
        
        if tag == appDelegate.currentLoopIdx {
            self.lblWord?.textColor = NSColor.blue
        } else {
            self.lblWord?.textColor = NSColor.black
        }
        if let currentState = self.mWord?["ignore"] as? Bool {
            self.btnIgnore.state = NSControl.StateValue(rawValue: currentState ? 1 : 0)
        }
        
    }
    
    
    @IBAction func didClickOnDeleteBtn(_ sender: Any) {
        if let callback = self.deleteWordCallback {
            callback(["tag" :self.mTag] )
        }
    }
    
    @IBAction func didClickOnWholeCellBtn(_ sender: Any) {
        if let callback = self.loadWordCallback {
            callback(["tag" :self.mTag , "word" : self.lblWord.stringValue ])
        }
    }
    
    @IBAction func didClickOnIgnoreBtn(_ sender: Any) {
        let currentState = self.btnIgnore.state
        
        self.mWord?["ignore"] = currentState == NSControl.StateValue.on;
        if let callback = self.ignoreCallBack {
            callback(["tag" :self.mTag , "ignore" : currentState == NSControl.StateValue.on])
        }
    }
}

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
   
    var mTag :Int = 0
    var mWord : Dictionary<String , String>? = nil
    var deleteWordCallback: CallBackClosure? = nil
    var loadWordCallback: CallBackClosure? = nil
    
    func setUpView(data : Dictionary<String , String> ,
                   tag : Int,
                   loadWordCallback : @escaping CallBackClosure ,
                   deleteWordCallback : @escaping CallBackClosure) {
        self.mTag = tag
        self.mWord = data
        self.deleteWordCallback = deleteWordCallback
        self.loadWordCallback = loadWordCallback
        
        if let text = self.mWord?["word"] {
            self.lblWord.stringValue = text
        }
        
        if tag == appDelegate.currentLoopIdx {
            self.lblWord?.textColor = NSColor.blue
        } else {
            self.lblWord?.textColor = NSColor.black
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
}

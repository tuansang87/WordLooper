//
//  CachedWordView.swift
//  Word Looper
//
//  Created by Sang Huynh on 4/25/17.
//  Copyright © 2017 GKXIM. All rights reserved.
//

import Cocoa

class CachedWordView: NSView, NSOutlineViewDelegate , NSOutlineViewDataSource {
    @IBOutlet weak var tbvContent: NSOutlineView!
    var arrOutlineItems : [Dictionary<String , Int>] = []
    var arrWords : [Dictionary<String , Any>]? = nil
    var loadWordCallback : CallBackClosure? = nil
     var dismissCallback : CallBackClosure? = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.registerNibCell()
        self.tbvContent.selectionHighlightStyle = .none
        self.reloadData()
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.prepareOutlineViewItems()
            self.tbvContent.reloadData()
        }
    }
    
    func setUpView(data : [Dictionary<String,Any>] ,
                   loadWordCallback: @escaping CallBackClosure ,
                   dismissCallback: @escaping CallBackClosure) {
        self.arrWords = data
        self.loadWordCallback = loadWordCallback
         self.dismissCallback = dismissCallback
        self.reloadData()
    }
    
    
    func registerNibCell() {
        self.tbvContent.register(NSNib.init(nibNamed: NSNib.Name(rawValue: "CachedWordViewCell"), bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CachedWordViewCellIdentifier"))
    }
    
    func prepareOutlineViewItems() {
         self.arrOutlineItems.removeAll()
        if let total = self.arrWords?.count {
           
            for index in 0 ..< total {
                self.arrOutlineItems.append(["row_index" : index])
                
            }

        }
        
    }
    
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any{
        if(index >= self.arrOutlineItems.count) {
            self.prepareOutlineViewItems()
        }
        
        return self.arrOutlineItems[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let total = self.arrWords?.count {
            return total
        }
        
        return 0
    }
    
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return 44.0
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        if let cell = self.tbvContent.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CachedWordViewCellIdentifier") , owner:nil) as?  CachedWordViewCell {
            if let item = item as? Dictionary<String,Int> {
                if let row_index = item["row_index"] {
                    if let data = self.arrWords?[row_index] {
                        cell.setUpView(data: data, tag: row_index, loadWordCallback:{[weak self] (resp) -> Void in
                            if let strongSelf = self {
                                if let row_index = resp["tag"] as? Int {
                                    if let data = strongSelf.arrWords?[row_index] {
                                        if let loadWordCallback = strongSelf.loadWordCallback {
                                            let dict = ["word" : data , "row_index" : row_index] as [String : Any]
                                            
                                            loadWordCallback(dict)
                                            strongSelf.didClickOnCancelBtn(sender: nil)
                                        }
                                    }
                                }
                                
                            }
                            
                            
                            }, deleteWordCallback: {[weak self] (resp) -> Void in
                                if let strongSelf = self {
                                    if let row_index = resp["tag"] {
                                        
                                        strongSelf.arrWords?.remove(at: row_index as! Int)
                                        let dict = [AppDelegate.kUserDictWords : strongSelf.arrWords! , AppDelegate.kUserDictDate : NSDate().timeIntervalSince1970] as [String : Any]
                                        
                                        UserDefaults.standard.set(dict, forKey: AppDelegate.kUserDict)
                                        
                                        UserDefaults.standard.synchronize()
                                        do {
                                            let destinationURL = NSURL(fileURLWithPath: kLocalGoogleDriveCachedFilePath)
                                            let dataObject = try JSONSerialization.data(withJSONObject: dict, options: [])
                                            try dataObject.write(to: destinationURL as URL , options: Data.WritingOptions.atomic)
                                        } catch let error as NSError {
                                            print(error.description)
                                        }
                                        
                                        
                                        let appDelegate =  NSApplication.shared.delegate as! AppDelegate
                                        appDelegate.words?.removeAll()
                                        for word in strongSelf.arrWords! {
                                            appDelegate.words?.append(word as NSDictionary)
                                        }
                                        strongSelf.reloadData()
                                    }
                                }
                                
                                
                            }, ignoreCallBack: {[weak self] (resp) -> Void in
                                if let strongSelf = self {
                                    if let row_index = resp["tag"] as? Int , let ignore = resp["ignore"] as? Bool {
                                        if var data = strongSelf.arrWords?[row_index] {
                                            appDelegate.addWord(word: data["word"] as! String, imagePath: data["image"] as? String, own_definition: data["own_definition"] as? String, audio: data["audio"] as? String, ignore: ignore)
                                        }
                                    }
                                }
                                
                                
                        })
                    }
                }
                
                
            }
            
            return cell
        }
        
        return nil
    }
    
    @IBAction func didClickOnCancelBtn(sender : NSButton?){
        if let dismissCallback = self.dismissCallback {
            dismissCallback([:])
        }
    }
 
}

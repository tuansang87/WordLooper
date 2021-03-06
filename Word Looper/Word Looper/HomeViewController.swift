//
//  ViewController.swift
//  Word Looper
//
//  Created by Sang Huynh on 4/24/17.
//  Copyright © 2017 GKXIM. All rights reserved.
//

import Cocoa
import WebKit
import AVFoundation

let appDelegate =  NSApplication.shared.delegate as! AppDelegate

let kiPhoneUserCustomAgent : String = "Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1"

let INTERVAL_LOOP_TIME = 5.0

let EMPTY_STR = ""



class HomeViewController: NSViewController, NSTextViewDelegate , NSTextFieldDelegate , NSTextDelegate , NSControlTextEditingDelegate {
    
    @IBOutlet weak var txtWord: NSTextField!
    @IBOutlet weak var searchInModeSegmentControl: NSSegmentedControl!
    @IBOutlet weak var serchInLanguageControl: NSSegmentedControl!
    
    @IBOutlet weak var txtSelfDefinition: NSTextView!
    @IBOutlet weak var txtImagePath: NSTextField!
    @IBOutlet weak var mWebSearchTopLayoutConstaint: NSLayoutConstraint!
    
    
    @IBOutlet weak var mWebSearchContainer: NSView!
    @IBOutlet weak var mWebSearch: WKWebView!
    
    @IBOutlet weak var btnImgPath: NSButton!
    @IBOutlet weak var btnLoop: NSButton!
    @IBOutlet weak var btnReset: NSButton!
    
    @IBOutlet weak var btnGoNext: NSButton!
    @IBOutlet weak var btnGoPrevious: NSButton!
    @IBOutlet weak var btnSync: NSButton!
    @IBOutlet weak var btnUp: NSButton!
    @IBOutlet weak var btnCached: NSButton!
    
    var player: AVAudioPlayer?
    var lastPlayWord: String?
    
    var _fileListFetchError : NSError?
    var _detailsFetchError : NSError?
    
    var _redirectHTTPHandler : OIDRedirectHTTPHandler?
    var _uploadFileTicket : GTLRServiceTicket?
    var _uploadProgressIndicator : NSProgressIndicator?
    
    lazy var driveService :GTLRDriveService = {
        let service :GTLRDriveService = GTLRDriveService()
        
        // Turn on the library's shouldFetchNextPages feature to ensure that all items
        // are fetched.  This applies to queries which return an object derived from
        // GTLRCollectionObject.
        service.shouldFetchNextPages = true;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically
        service.isRetryEnabled = true;
        
        return service
    }()
    
    var cachedView : CachedWordView? = nil
    var shouldDoLoop = true
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var frame = self.view.frame
        let screenSize = NSScreen.main!.frame.size
        
        frame.size.width = 375
        frame.size.height = screenSize.height - 100
        self.view.frame = frame
        
        self.mWebSearch = WKWebView()
        self.mWebSearch.navigationDelegate = self
        self.mWebSearch.frame = self.mWebSearchContainer.bounds
        self.mWebSearch.customUserAgent = kiPhoneUserCustomAgent
        self.mWebSearchContainer.addSubview(self.mWebSearch)
        // Do any additional setup after loading the view.
        self.mWebSearchTopLayoutConstaint.constant = 30.0
        self.txtImagePath.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(hotkey(noti:)), name: NSNotification.Name(rawValue: HOTKEYCODE_QUICK_COMMAND_NOTI), object: nil)
    }
    
    
    override func viewDidAppear() {
        
        self.mWebSearch.frame = self.mWebSearchContainer.bounds
        
        var constraint = NSLayoutConstraint(item: self.mWebSearch, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.mWebSearchContainer, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: 0.0);
        self.view.addConstraint(constraint);
        
        constraint = NSLayoutConstraint(item: self.mWebSearch, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.mWebSearchContainer, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0.0);
        self.view.addConstraint(constraint);
        //          GOOGLE
        //        constraint = NSLayoutConstraint(item: self.mWebSearch, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.mWebSearchContainer, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: -100.0);
        // DUCKDUCKGO // Bing
        constraint = NSLayoutConstraint(item: self.mWebSearch, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.mWebSearchContainer, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: -100.0);
        self.view.addConstraint(constraint);
        
        constraint = NSLayoutConstraint(item: self.mWebSearch, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.mWebSearchContainer, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0.0);
        self.view.addConstraint(constraint)
        self.view.window?.makeFirstResponder(self.txtWord)
        
        self.btnGoNext.isHighlighted = appDelegate.loopDirection
        self.btnGoPrevious.isHighlighted = !appDelegate.loopDirection
        
        
        self.btnLoop.state =  NSControl.StateValue.on
        self.didClickOnLoopBtn(self.btnLoop)
        
        DriveUtils.sharedDrive().configClientId(kClientId, clientSecret: kClientSecret, fileId: kWordLooperFileID, successString: kSuccessURLString)
        if DriveUtils.sharedDrive().isSignedIn() == true {
            //            self.btnSync.title = "Sign Out"
            self.btnUp.isHidden = false
        } else {
            // Sign out
            //            self.btnSync.title = "Sync"
            self.btnUp.isHidden = true
        }
        
        self.didClickSyncBtn(nil)
    }
    
    
    
    func loadDefinition(word : Dictionary<String , Any>) {
        if word.keys.count > 0 {
            self.showIndicator()
            
            // GOOGLE
            //            var queri = "https://www.google.com/search?q=\(text)&ie=utf-8&oe=utf-8&aq=t"
            //            if appDelegate.searchMode == "image" {
            //                queri =  "\(queri)&tbm=isch"
            //            } else if appDelegate.searchMode == "news" {
            //                queri =  "\(queri)&tbm=nws"
            //            }
            
            // DUCKDUCKGO
            //            var queri = "https://duckduckgo.com/?q=\(text)&t=ha"
            //            if appDelegate.searchMode == "image" {
            //                queri =  "\(queri)&tbm=images"
            //            } else {
            //                queri =  "\(queri)&ia=definition"
            //            }
            // BING
            
            let vocab = word["word"]!
            self.txtWord.stringValue = vocab as! String
            let isEng2VN = self.serchInLanguageControl.selectedSegment == 1;
            let searchByImage = appDelegate.searchMode == .image;
            if isEng2VN && !searchByImage {
                var text  = "\(vocab)"
                text = text.replacingOccurrences(of: " ", with: "+")
                
                let queri = "http://translate.google.com/?tl=vi#auto/vi/\(text)"
                if let url = URL(string:queri) {
                    let request = URLRequest(url:url)
                    self.mWebSearch.load(request)
                }
                
                
            } else {
                var text  = "define \(word["word"]!)"
                text = text.replacingOccurrences(of: " ", with: "+")
                if let imgPath = word["image"] as? String{
                    self.btnImgPath.state =  NSControl.StateValue.on
                    mWebSearchTopLayoutConstaint.constant = self.btnImgPath.state ==  NSControl.StateValue.on ? 50 : 30
                    self.txtImagePath.isHidden = self.btnImgPath.state ==  NSControl.StateValue.off
                    
                    self.txtImagePath.stringValue = imgPath
                    let url = URL(string:imgPath)!
                    let request = URLRequest(url:url)
                    self.mWebSearch.load(request)
                } else {
                    self.btnImgPath.state =  NSControl.StateValue.off
                    mWebSearchTopLayoutConstaint.constant = self.btnImgPath.state ==  NSControl.StateValue.on ? 50 : 30
                    self.txtImagePath.isHidden = self.btnImgPath.state ==  NSControl.StateValue.off
                    
                    self.txtImagePath.stringValue = EMPTY_STR
                    var queri = "https://www.bing.com/search?q=\(text)"
                    if appDelegate.searchMode == .image {
                        queri = "https://www.bing.com/images/search?q=\(text)"
                        queri =  "\(queri)&FORM=HDRSC2"
                    } else {
                        queri =  "\(queri)&FORM=HDRSC1"
                    }
                    
                    var selectedIdx = 0;
                    if appDelegate.searchMode == .image {
                        selectedIdx = 1;
                    } else if appDelegate.searchMode == .new {
                        selectedIdx = 2;
                    }
                    self.searchInModeSegmentControl.selectSegment(withTag: selectedIdx)
                    
                    
                    if let url = URL(string:queri) {
                        let request = URLRequest(url:url)
                        self.mWebSearch.load(request)
                    }
                    
                }
                
                if let own_defi = word["own_definition"] as? String {
                    self.txtSelfDefinition.string = own_defi
                } else {
                    self.txtSelfDefinition.string = EMPTY_STR
                }
                
            }
            
            
        }
        
    }
    
    
    
    func loadNib(named nibName:String, owner:Any?) -> [NSView] {
        var topLevelObjects : NSArray?
        if Bundle.main.loadNibNamed(NSNib.Name(rawValue: nibName), owner: self, topLevelObjects: &topLevelObjects) {
            if let arr = topLevelObjects as? Array<Any> {
                let views = arr.filter { $0 is NSView }
                return views as! [NSView];
            }
            
        }
        return [];
    }
    
    
    
    func stopLoop(){
        
        self.btnLoop.state =  NSControl.StateValue.off
        shouldDoLoop = false
    }
    
    func doLoop(){
        if(self.shouldDoLoop) {
            self.loadCachedWord()
        }
        
    }
    
    
    func loadCachedWord() {
        guard let words = appDelegate.words else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(3), execute: {[weak self] () in
                // do something
                guard let strongSelf = self else {
                    return
                }
                strongSelf.doLoop()
            })
            return
            
        }
        if appDelegate.loopDirection == true // go next {
        {
            if appDelegate.currentLoopIdx < 0 || appDelegate.currentLoopIdx > words.count - 1 {
                appDelegate.currentLoopIdx = 0
            }
        } else // go previous
        {
            if appDelegate.currentLoopIdx < 0 || appDelegate.currentLoopIdx > words.count - 1 {
                appDelegate.currentLoopIdx = words.count - 1
            }
        }
        
        
        
        if(words.count > 0) {
            let idx = appDelegate.currentLoopIdx
            if appDelegate.loopDirection == true // go next {
            {
                if(idx < words.count - 1) {
                    
                    appDelegate.currentLoopIdx += 1
                } else {
                    appDelegate.currentLoopIdx = 0
                }
            } else // go previous
            {
                if(idx > 0) {
                    
                    appDelegate.currentLoopIdx -= 1
                } else {
                    appDelegate.currentLoopIdx = words.count - 1
                }
            }
            
          
            // load here
            
            let word = words[idx]
            if let shouldIgnore = word["ignore"] as? Bool {
                if shouldIgnore == true {
                    self.loadCachedWord();
                    return;
                }
            }
            if let key = word["word"] as? String {
                self.txtWord.stringValue = key
                if let ownDefinition = word["own_definition"] as? String {
                    self.txtSelfDefinition.string = ownDefinition
                }
                /*
                else {
                    self.loadDefinition(word:word as! Dictionary<String, Any>)
                }
                */
                self.loadDefinition(word:word as! Dictionary<String, Any>)
                
                let image = word["image"] as? String;
                let own_definition = word["own_definition"] as? String;
                var ignore = false
                
                if let tmp = word["ignore"] as? Bool {
                    ignore = tmp
                }
                
                self.fecthAudioFileForWord(word: word["word"] as! String) { (link , linkWord) in
                    if (linkWord == key) {
                        appDelegate.addWord(word: key, imagePath:  image  , own_definition: own_definition , audio : link , ignore: ignore, forgot: false);
                        
                        
                    }
                    self.playSound(soundUrl: link)
                }
                
            }
            
            
            if let imgPath = word["image"] as? String {
                // handle here
                txtImagePath.stringValue = imgPath
            }
        } else {
            self.stopLoop()
        }
        
        
    }
    
    var progressIndicator: NSProgressIndicator?
    func showIndicator(){
        if let _ = self.progressIndicator {
            self.progressIndicator?.isHidden = false
            
        } else {
            self.progressIndicator = NSProgressIndicator()
        }
        
        if let windView =  NSApp.mainWindow?.contentView {
            self.progressIndicator?.frame = NSRect(x:self.mWebSearch.frame.origin.x, y: self.mWebSearch.frame.origin.y + 30 /*+ self.mWebSearch.frame.size.height -100 - 20*/, width:self.view.frame.size.width, height:20)
            self.progressIndicator?.startAnimation(nil)
            
            windView.addSubview(self.progressIndicator!)
        }
        
        
    }
    
    func hideIndicator(){
        self.progressIndicator?.stopAnimation(nil)
        self.progressIndicator?.isHidden = true
    }
    
    @IBAction func didClickOnSearchLanguageSegMentControl(_ sender: NSSegmentedControl) {
        self.loadDefinition(word: ["word": self.txtWord.stringValue])
    }
    
    
    @IBAction func didClickOnSearchModeSegMentControl(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            appDelegate.searchMode = .all
        case 1:
            appDelegate.searchMode = .image
        default:
            appDelegate.searchMode = .all
        }
        
        self.loadDefinition(word: ["word": self.txtWord.stringValue])
    }
    
    
    @IBAction func didClickOnLoopBtn(_ sender: NSButton) {
        let lastState = self.btnLoop.state
        switch lastState {
        case  NSControl.StateValue.off :
            self.stopLoop()
            self.shouldDoLoop = false
        case  NSControl.StateValue.on :
            self.shouldDoLoop = true
            self.doLoop()
        default:
            self.stopLoop()
        }
        
        self.btnLoop.state = lastState
        
    }
    
    @IBAction func didClickOnSaveWordBtn(_ sender: NSButton?) {
        appDelegate.addWord(word: self.txtWord.stringValue, imagePath: self.txtImagePath.stringValue, own_definition: self.txtSelfDefinition.string , audio: nil , ignore: false, forgot: false);
    }
    
    
    @IBAction func didClickOnResetBtn(_ sender: NSButton?) {
        self.stopLoop()
        appDelegate.currentLoopIdx = 0
        self.btnLoop.state =  NSControl.StateValue.on
        self.didClickOnLoopBtn(self.btnLoop)
    }
    
    
    @IBAction func didClickOnImagePathWordBtn(_ sender: NSButton) {
        self.stopLoop()
        mWebSearchTopLayoutConstaint.constant = sender.state ==  NSControl.StateValue.on ? 50 : 30
        self.txtImagePath.isHidden = sender.state ==  NSControl.StateValue.off
        
    }
    
    @IBAction func goNextCachedWord(_ sender: NSButton?) {
        appDelegate.loopDirection = true
        let delayTime = DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.btnGoNext.isHighlighted = appDelegate.loopDirection
            self.btnGoPrevious.isHighlighted = !appDelegate.loopDirection
        }
        
        self.txtImagePath.stringValue = EMPTY_STR
        
        guard appDelegate.words != nil else {
            return
        }
        
        self.btnLoop.state =  NSControl.StateValue.on
        self.didClickOnLoopBtn(self.btnLoop)
    }
    
    @IBAction func goPreviousCachedWord(_ sender: NSButton?) {
        appDelegate.loopDirection = false
        let delayTime = DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.btnGoNext.isHighlighted = appDelegate.loopDirection
            self.btnGoPrevious.isHighlighted = !appDelegate.loopDirection
        }
        
        self.txtImagePath.stringValue = EMPTY_STR
        
        guard appDelegate.words != nil else {
            return
        }
        
        self.btnLoop.state =  NSControl.StateValue.on
        self.didClickOnLoopBtn(self.btnLoop)
    }
    
    
    @IBAction func didClickOnCachedWords(_ sender : NSButton?) {
        //        self.stopLoop()
        if let cachedView = self.cachedView {
            if(cachedView.isHidden == true) {
                cachedView.isHidden = false
            } else {
                cachedView.isHidden = true
                return
            }
            
        } else {
            let arr = self.loadNib(named: "CachedWordView", owner: nil)
            if arr.count > 0 {
                if let view = arr.first as? CachedWordView {
                    self.view .addSubview(view)
                    view.frame = self.view.bounds;
                    self.cachedView = view
                }
            }
        }
        
        self.cachedView?.setUpView(data: appDelegate.words! as! [Dictionary<String, Any>], loadWordCallback: {[weak self] (resp) in
            if let strongSelf = self {
                if let currentLoopIdx = resp["row_index"] as? Int {
                    appDelegate.currentLoopIdx = currentLoopIdx
                }
                
                if let word = resp["word"] as? Dictionary<String , Any> {
                    strongSelf.loadDefinition(word:word)
                    if let key = word["word"] as? String {
                        let image = word["image"] as? String ;
                        let own_definition = word["own_definition"] as? String ;
                        var ignore = false
                        
                        if let tmp = word["ignore"] as? Bool {
                            ignore = tmp
                        }
                        
                        strongSelf.lastPlayWord = nil
                        strongSelf.fecthAudioFileForWord(word: key) { (link , linkWord) in
                            
                            if (linkWord == key) {
                                
                                
                                appDelegate.addWord(word: key, imagePath:  image  , own_definition: own_definition , audio : link , ignore: ignore , forgot: false);
                                
                                
                            }
                            strongSelf.playSound(soundUrl: link)
                        }
                        
                    }
                    
                }
                
            }
            }, dismissCallback: {[weak self] (resp) in
                if let strongSelf = self {
                    weak var weakSelf = strongSelf
                    DispatchQueue.main.async(execute: {
                        if let strongSelf = weakSelf {
                            strongSelf.cachedView?.isHidden = true
                        }
                        
                    })
                }
        })
        
    }
    @IBAction func didClickSyncBtn(_ sender : NSButton?){
        self.signInGoogle()
    }
    
    
    @IBAction func didClickUpLoadDriveBtn(_ sender : NSButton?){
        self.uploadDataToDrive()
    }
    
    @IBAction func didClickOnAudioBtn(_ sender : Any?) {
        self.lastPlayWord = nil
        if self.txtWord.stringValue.characters.count > 0{
            self.fecthAudioFileForWord(word: self.txtWord.stringValue, callback: { (link , linkWord) in
                
                self.playSound(soundUrl: link)
            })
        }
    }
    
}
private typealias TableViewDataSource = HomeViewController
extension TableViewDataSource  {
    
    func textDidBeginEditing(_ obj: Notification) {
        self.stopLoop()
        
    }
    
    override func controlTextDidBeginEditing(_ obj: Notification) {
        self.stopLoop()
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        
        if let txt = obj.object  as? NSTextField{
            if txt == self.txtWord {
                if (txt.stringValue as NSString).scriptingBegins(with: "http") {
                    if let url = URL(string: txt.stringValue) {
                        let request = URLRequest(url:url)
                        self.mWebSearch.load(request as URLRequest)
                    }
                    
                    
                } else {
                    if self.txtWord.stringValue.characters.count > 0{
                        self.fecthAudioFileForWord(word: self.txtWord.stringValue, callback: { (link , linkWord) in
                            self.playSound(soundUrl: link)
                        })
                    }
                }
                
            }
        }
    }
    
    
    override func controlTextDidChange(_ obj: Notification) {
        let delayTime = DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            if let txt = obj.object as? NSTextField {
                if  txt == self.txtWord {
                    let text = self.txtWord.stringValue;
                    self.highlightIfNeeded(text)
                    self.loadDefinition(word: ["word": text])
                } else if txt == self.txtImagePath {
                    
                    let queri  = txt.stringValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    if queri.characters.count > 0 {
                        let url = URL(string:queri)!
                        let request = URLRequest(url:url)
                        self.mWebSearch.load(request)
                    }  else {
                        // do nothing
                    }
                    
                } else {
                    // do nothing
                }
                
            }
            
        }
        
    }
    
    func highlightIfNeeded(_ word : String) {
        if(word.characters.count > 0) {
            if(appDelegate.isWordExisted(word: word)) {
                self.btnCached.highlight(true)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(500), execute: {[weak self] () in
                    // do something
                    guard let strongSelf = self else {
                        return
                    }
                    
                    strongSelf.btnCached.highlight(false)
                })
            }
        }
        
    }
    
}


typealias ViewControllerWebDelegate = HomeViewController

extension ViewControllerWebDelegate : WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void){
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
        self.hideIndicator()
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(delayAndGoNextWord), with: nil, afterDelay: INTERVAL_LOOP_TIME)
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.hideIndicator()
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(delayAndGoNextWord), with: nil, afterDelay: INTERVAL_LOOP_TIME)
        
    }
    
    @objc func delayAndGoNextWord(){
        if(self.shouldDoLoop) {
            self.loadCachedWord()
        }
    }
}



typealias ViewControllerGoogleDriveAPIs = HomeViewController
extension ViewControllerGoogleDriveAPIs {
    
    func downLoadDriveData(){
        let destinationURL = URL(fileURLWithPath: kLocalGoogleDriveCachedFilePath)
        DriveUtils.sharedDrive().downloadFile(kWordLooperFileID, destinationURL: destinationURL, withHandler: { (driveData) in
            do {
                // Insert code here to initialize your application
                if let tmp = UserDefaults.standard.object(forKey: AppDelegate.kUserDict) as? NSDictionary {
                    if (tmp[AppDelegate.kUserDictWords] as? [NSDictionary]) != nil {
                        let inAppInterval = tmp[AppDelegate.kUserDictDate] as! Double
                        
                        let cachedData = NSData(contentsOfFile: kLocalGoogleDriveCachedFilePath)
                        if cachedData != nil
                        {
                            if let jsonObject = try JSONSerialization.jsonObject(with: driveData! as Data, options: []) as? NSDictionary {
                                let timeInterval = jsonObject[AppDelegate.kUserDictDate] as! Double
                                
                                if(timeInterval > inAppInterval) {
                                    let destinationURL = NSURL(fileURLWithPath: kLocalGoogleDriveCachedFilePath)
                                    try driveData?.write(to: destinationURL as URL , options: Data.WritingOptions.atomic)
                                    
                                    
                                    if let words = jsonObject[AppDelegate.kUserDictWords] as? [NSDictionary] {
                                        appDelegate.words = NSMutableArray(array: words) as? [NSDictionary]
                                    }
                                    
                                }
                            }
                            
                        }
                    }
                }
                
                
            } catch let error as NSError {
                print(error.description)
            }
        })
    }
    
    func signInGoogle(){
        
        
        if DriveUtils.sharedDrive().isSignedIn() == false {
            // Sign in
            DriveUtils.sharedDrive().runSigninThenHandler({
                //             self.btnSync.title = "Sign Out"
                self.downLoadDriveData()
            })
            
            
        } else {
            // Sign out
            //            self.btnSync.title = "Sign Out"
            self.downLoadDriveData()
        }
        
        
        
    }
    
    func uploadDataToDrive(){
        
        
        if DriveUtils.sharedDrive().isSignedIn() == true {
            // Sign in
            DriveUtils.sharedDrive().uploadFile(atPath: kLocalGoogleDriveCachedFilePath)
        }
    }
    
    
    
}
typealias AudioFinding = HomeViewController

extension AudioFinding {
    
    @objc func downloadAndPlay(soundUrl :String){
        if let url = URL(string: soundUrl) {
            do {
                
                let data = try Data(contentsOf: url)
                DispatchQueue.main.async {
                    do {
                        
                        self.player = try AVAudioPlayer(data: data)
                        guard let player = self.player else { return }
                        
                        player.prepareToPlay()
                        player.play()
                    } catch let error {
                        print(error.localizedDescription)
                    }
                    
                    
                }
                
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func playSound(soundUrl :String) {
        
        self.performSelector(inBackground: #selector(downloadAndPlay(soundUrl:)), with: soundUrl)
        
        
    }
    
    func getAutioFileFromSource(src : NSString) -> String {
        let contentUrlStr = "<source src="
        var beginPos = 0
        let srcLength = src.length
        
        var searchLength = srcLength - beginPos
        while (beginPos < srcLength) {
            let contentUrlRange = src.range(of: contentUrlStr , options: [], range: NSMakeRange(beginPos, searchLength))
            if contentUrlRange.location != NSNotFound {
                let doubleQuoteStr = "\""
                let newPos = contentUrlRange.location + contentUrlRange.length
                let rangeLength = src.length - newPos
                
                let doubleQuoteRange = src.range(of: doubleQuoteStr, options: [], range: NSMakeRange(newPos, rangeLength))
                if doubleQuoteRange.location != NSNotFound {
                    
                    let newPos = doubleQuoteRange.location + doubleQuoteRange.length
                    let rangeLength = src.length - newPos
                    
                    let endDoubleQuoteRange = src.range(of: doubleQuoteStr, options: [], range: NSMakeRange(newPos, rangeLength))
                    if endDoubleQuoteRange.location != NSNotFound {
                        let link = src.substring(with: NSMakeRange(newPos, endDoubleQuoteRange.location - newPos))
                        if link.contains("mp3") {
                            return link
                        }
                        
                        beginPos = endDoubleQuoteRange.location + 1
                        searchLength = src.length - beginPos
                    } else {
                        break
                    }
                }
            }
        }
        
        return EMPTY_STR
    }
    func fecthAudioFileForWord(word : String , callback : @escaping (_ link : String , _ word: String) -> Void ) {
        if let lastWord = self.lastPlayWord {
            if lastWord == word {
                return
            }
        }
        self.lastPlayWord = word
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        var text  = word
        text = text.replacingOccurrences(of: " ", with: "+")
        if let url = URL(string: "http://www.dictionary.com/browse/\(text)?s=t") {
            let dataTask = session.dataTask(with: url) { (data, resp, err) in
                guard let data = data  else {
                    return
                }
                
                if let returnData = String(data: data, encoding: .utf8) {
                    let link = self.getAutioFileFromSource(src: returnData as NSString)
                    callback(link , text)
                }
                
                
                
            }
            
            dataTask.resume()
        }
        
        
        
    }
    
    
}

typealias ControlText = HomeViewController

extension ControlText {
    @objc func hotkey(noti : NSNotification?) {
        if let noti = noti  {
            if let obj = noti.object as? String {
                
                if obj == kHotKeyReset {
                    self.didClickOnResetBtn(nil)
                } else if obj == kGoNextWord {
                    self.goNextCachedWord(nil)
                } else if obj == kGoPreviousWord {
                    self.goPreviousCachedWord(nil)
                } else if obj == kPlayCurrentWord {
                    self.didClickOnAudioBtn(nil)
                } else if obj == kOpenCachedWords {
                    self.didClickOnCachedWords(nil);
                } else if obj == kOpenHome {
                    self.cachedView?.isHidden = true
                } else if obj == kSaveWord {
                    self.didClickOnSaveWordBtn(nil);
                } else if obj == kLoop {
                    
                    self.btnLoop.state = self.btnLoop.state == NSControl.StateValue.on ? NSControl.StateValue.off :  NSControl.StateValue.on
                    self.didClickOnLoopBtn(self.btnLoop);
                } else if obj == kLookUpInEnglish {
                    self.serchInLanguageControl.selectSegment(withTag: 0)
                    self.didClickOnSearchLanguageSegMentControl(self.serchInLanguageControl)
                } else if obj == kLookUpInVietnamese {
                    self.serchInLanguageControl.selectSegment(withTag: 1)
                    self.didClickOnSearchLanguageSegMentControl(self.serchInLanguageControl)
                } else if obj == kSearchByWeb {
                    self.searchInModeSegmentControl.selectSegment(withTag: 0)
                    self.didClickOnSearchModeSegMentControl(self.searchInModeSegmentControl)
                } else if obj == kSearchByImage {
                    self.searchInModeSegmentControl.selectSegment(withTag: 1)
                    self.didClickOnSearchModeSegMentControl(self.searchInModeSegmentControl)
                }
            }
        }
    }
    
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if let event = NSApp.currentEvent {
            AppDelegate.handleHotkey(with: event)
        }
        
        control.sendAction(commandSelector, to: nil);
        return true;
    }
    
    func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if let event = NSApp.currentEvent {
            AppDelegate.handleHotkey(with: event)
        }
        textView.perform(commandSelector, with: textView);
        return true;
    }
}


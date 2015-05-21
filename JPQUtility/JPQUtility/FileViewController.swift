//
//  ViewController.swift
//  JPQUtility
//
//  Created by Jared Jones on 11/2/14.
//  Copyright (c) 2014 Uvora. All rights reserved.
//

import Cocoa

class FileViewController: NSViewController {
    
    @IBOutlet var toolbarVisualEffectsView: NSVisualEffectView!
    @IBOutlet weak var jpqModifierView: NSView!
    @IBOutlet weak var fileModifierView: NSView!
    @IBOutlet weak var addJPQButton: NSButton!
    @IBOutlet weak var addJPQLabel: NSTextField!
    @IBOutlet weak var loadJPQButton: NSButton!
    @IBOutlet weak var unloadJPQButton: NSButton!

//    @IBOutlet weak var fileTableView: FileTableView!

    var fileOutlineScrollView: FileScrollView!
    
    var savePanel:NSSavePanel?
    var openPanel:NSOpenPanel?
    var loadedJPQFile:JPQFileSwiftBridge?
    var addJPQPop = NSPopover()
    var addJPQPopVC = AddJPQPopover(nibName: "AddJPQPopover", bundle: nil)!
    
    required init?(coder: NSCoder) {
        fileOutlineScrollView = FileScrollView()
        var tableView:NSTableView = NSTableView(frame: NSMakeRect(0, 0, 364, 200))
        var column1 = NSTableColumn(identifier: "Col1")
        var column2 = NSTableColumn(identifier: "Col2")
        column1.width = 252
        column2.width = 198
        
        tableView.addTableColumn(column1)
        tableView.addTableColumn(column2)
        tableView.reloadData()
        
        fileOutlineScrollView.documentView = tableView
        fileOutlineScrollView.hasVerticalScroller = true
        
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        fileTableView.controller = self
//        fileTableView.registerForDraggedTypes(NSArray(objects:  NSURLPboardType) as [AnyObject])
        
        
        
        
        savePanel = NSSavePanel()
        savePanel!.nameFieldLabel = "JPQ Name:"
        savePanel!.nameFieldStringValue = "file.JPQ"
        savePanel!.allowedFileTypes = ["JPQ"]
        savePanel!.allowsOtherFileTypes = false
        savePanel!.extensionHidden = false
        savePanel!.canCreateDirectories = true
        
        openPanel = NSOpenPanel()
        openPanel!.nameFieldLabel = "JPQ Name:"
        openPanel!.nameFieldStringValue = "file.JPQ"
        openPanel!.allowedFileTypes = ["JPQ"]
        openPanel!.allowsOtherFileTypes = false
        openPanel!.extensionHidden = false
        
        toolbarVisualEffectsView.state = NSVisualEffectState.FollowsWindowActiveState
        toolbarVisualEffectsView.material = NSVisualEffectMaterial.Titlebar
        toolbarVisualEffectsView.blendingMode = NSVisualEffectBlendingMode.BehindWindow
        
        addJPQPop.contentViewController = addJPQPopVC
        addJPQPop.behavior = NSPopoverBehavior.Semitransient
        addJPQPopVC.holder = self;
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        var frame = view.window!.frame
        frame.size.height = 74
        frame.size.width = 640
        view.window!.setFrame(frame, display: true, animate: false)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    
    @IBAction func addJPQButtonAction(sender: NSButton)
    {
        // Since running the savePanel will hault the sender action from returning
        // we must prompt the save panel asyncronously
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.addJPQPop.showRelativeToRect(NSRect(x: 0, y: 0, width: 250, height: 160), ofView: self.addJPQLabel, preferredEdge: NSMaxYEdge)
            })
        return
    }
    
    var constList:Array<NSLayoutConstraint>?
    @IBAction func loadJPQActionButton(sender: NSButton)
    {
        /*
        addJPQButton.enabled = false
        loadJPQButton.enabled = false
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.openPanel!.beginWithCompletionHandler({ (result:Int) -> Void in
                if result == NSFileHandlingPanelOKButton
                {
                    self.loadJPQFile(self.openPanel!.URL!)
                }
            })
            self.addJPQButton.enabled = true
            self.loadJPQButton.enabled = true
        })*/
        
        if !fileOutlineScrollView.isDescendantOf(self.view)
        {
            fileOutlineScrollView.frame = CGRectMake(0, 0, 0, 0)
            self.view.addSubview(fileOutlineScrollView)
            self.constList = addConstraintForBottomSection(fileOutlineScrollView)
            
            var frame = view.window!.frame
            frame.size.height = 500
            view.window!.setFrame(frame, display: true, animate: true)
        }
        else
        {
            FileViewController.removeConstraintsFromView(view: self.view, withConstraints: self.constList!)
            
            fileOutlineScrollView.animator().removeFromSuperview()
            
            var frame = view.window!.frame
            frame.size.height = self.toolbarVisualEffectsView.frame.height
            view.window!.setFrame(frame, display: true, animate: true)
        }
    }
    
    @IBAction func unloadJPQPressed(sender: NSButton)
    {
        self.loadedJPQFile = nil;
        self.jpqModifierView.hidden = false
        self.fileModifierView.hidden = true
    }
    
    func addConstraintForBottomSection(view: NSView) -> Array<NSLayoutConstraint>
    {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let bottom = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: toolbarVisualEffectsView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        let leading = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
        
        self.view.addConstraint(bottom)
        self.view.addConstraint(trailing)
        self.view.addConstraint(top)
        self.view.addConstraint(leading)
        
        return [bottom, trailing, top, leading]
    }
    
    class func removeConstraintsFromView(view _view:NSView, withConstraints constArray:Array<NSLayoutConstraint>)
    {
        for constraint in constArray
        {
            _view.removeConstraint(constraint)
        }
    }
    
    func createJPQFilePrompt(maxFiles:UInt64, filePositionByteSize:UInt8)
    {
        addJPQButton.enabled = false
        loadJPQButton.enabled = false
        
        // Since running the savePanel will hault the sender action from returning
        // we must prompt the save panel asyncronously
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.savePanel!.beginWithCompletionHandler { (result: Int) -> Void in
                if result == NSFileHandlingPanelOKButton
                {
                    if let fileLocation = self.savePanel?.URL?.path
                    {
                        self.saveJPQFile(fileLocation, maxFiles: maxFiles, filePositionByteSize: filePositionByteSize, replace: false)
                    }
                    else
                    {
                        self.dispatchStandardAlert("JPQFile Failed to Save!", body: "The file location you're attemping to save to is invalid aka nil.",
                            style: NSAlertStyle.WarningAlertStyle)
                    }
                }
                self.addJPQButton.enabled = true
                self.loadJPQButton.enabled = true
            }
            
            //dispatch_async must return void
            return
        })
    }
    
    func loadJPQFile(jpqFilePath:NSURL)
    {
        var jpqFile = JPQLibSwiftBridge.LoadJPQPackage(jpqFilePath.path)
        if jpqFile != nil
        {
            self.jpqModifierView.hidden = true
            self.fileModifierView.hidden = false
            self.loadedJPQFile = jpqFile
            
            var fileSize:UInt64 = 0
            let fileData:NSData = self.loadedJPQFile!.LoadFile("/dufus/marcus/(jpqdir)", withFileSize:&fileSize)
            
            let fileStuff:NSString = NSString(data: fileData, encoding: NSUTF8StringEncoding)!
            
            println("Size:\(fileSize)")
            println("StringLength:\(fileStuff.length)")
            println("Stuff:\(fileStuff)")
        }
    }
    
    func saveJPQFile(fileLocation:String, maxFiles:UInt64, filePositionByteSize:UInt8, replace:Bool = false) -> Void
    {
        var jpqFile = JPQLibSwiftBridge.CreateJPQPackage(fileLocation,
            withOverwriteFile: replace,
            withMaxNumberOfFiles: NSNumber(unsignedLongLong: maxFiles),
            withVersion: nil,
            withFilePositionSizeInBytes: NSNumber(unsignedChar: filePositionByteSize))
        if ((jpqFile) != nil)
        {
            if jpqFile.errorCode != 0
            {
                switch jpqFile.errorCode
                {
                case 1:
                    self.dispatchStandardAlert("JPQFile Failed to Save!",
                        body: "An unknown error has occured that has prevented the JPQFile from saving.",
                        style: NSAlertStyle.WarningAlertStyle)
                case 2:
                    let alert = NSAlert()
                    alert.addButtonWithTitle("Cancel")
                    alert.addButtonWithTitle("Overwrite File");
                    alert.messageText = "JPQFile Already Exists!"
                    alert.informativeText = "The JPQFile already exists!\rAre you sure you want to overwrite the file?\rThere is no going back!"
                    alert.alertStyle = NSAlertStyle.CriticalAlertStyle
                    alert.beginSheetModalForWindow(self.view.window!, completionHandler: { (NSModalResponse) -> Void in
                        if NSModalResponse == NSAlertSecondButtonReturn
                        {
                            self.saveJPQFile(fileLocation, maxFiles: maxFiles, filePositionByteSize: filePositionByteSize, replace: true)
                        }
                    })
                case 4:
                    self.dispatchStandardAlert("JPQFile Failed to Save!",
                        body: "OS X has denied you write access to the location you've chosen!",
                        style: NSAlertStyle.WarningAlertStyle)
                case 8:
                    self.dispatchStandardAlert("JPQFile Failed to Save!",
                        body: "OS X has denied you read access to the location you've chosen!",
                        style: NSAlertStyle.WarningAlertStyle)
                default:
                    break
                }
            }
            else
            {
                addJPQPop.close()
                self.jpqModifierView.hidden = true
                self.fileModifierView.hidden = false
                self.loadedJPQFile = jpqFile
            }
        }
        else
        {
            self.dispatchStandardAlert("JPQFile Failed to Save!",
                body: "An unknown error has occured that has prevented the file from saving. The JPQFile was returned as nil to the program.",
                style: NSAlertStyle.WarningAlertStyle)
        }
    }
    
    func addFile(fileLocation:String, replace:Bool = false) -> Void
    {
        
    }
    
    func dispatchStandardAlert(title:String, body:String, style:NSAlertStyle)
    {
        let alert = NSAlert()
        alert.addButtonWithTitle("Continue")
        alert.messageText = title
        alert.informativeText = body
        alert.alertStyle = style
        alert.beginSheetModalForWindow(self.view.window!, completionHandler: { (NSModalResponse) -> Void in
            
        })
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}


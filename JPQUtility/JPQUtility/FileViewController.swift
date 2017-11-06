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
    
    //TODO: Make this atomic when swift implemented this
    var loadedJPQFile:JPQFileSwiftBridge?
    var addJPQPop = NSPopover()
    var addJPQPopVC = AddJPQPopover(nibName: NSNib.Name(rawValue: "AddJPQPopover"), bundle:nil)
    
    required init?(coder: NSCoder) {
        fileOutlineScrollView = FileScrollView()
        let tableView:NSTableView = NSTableView(frame: NSMakeRect(0, 0, 364, 200))
        let column1 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "Col1"))
        let column2 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "Col2"))
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
        savePanel!.isExtensionHidden = false
        savePanel!.canCreateDirectories = true
        
        openPanel = NSOpenPanel()
        openPanel!.nameFieldLabel = "JPQ Name:"
        openPanel!.nameFieldStringValue = "file.JPQ"
        openPanel!.allowedFileTypes = ["JPQ"]
        openPanel!.allowsOtherFileTypes = false
        openPanel!.isExtensionHidden = false
        
        toolbarVisualEffectsView.state = NSVisualEffectView.State.followsWindowActiveState
        toolbarVisualEffectsView.material = NSVisualEffectView.Material.titlebar
        toolbarVisualEffectsView.blendingMode = NSVisualEffectView.BlendingMode.behindWindow
        
        addJPQPop.contentViewController = addJPQPopVC
        addJPQPop.behavior = NSPopover.Behavior.semitransient
        addJPQPopVC.holder = self;
        
        // Do any additional setup after loading the view.
    }
    
    var firstTimeViewAppeared = true
    override func viewWillAppear() {
        super.viewWillAppear()
        
        if (firstTimeViewAppeared)
        {
            var frame = view.window!.frame
            frame.size.height = 74
            frame.size.width = 640
            view.window!.setFrame(frame, display: true, animate: false)
            firstTimeViewAppeared = false
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    
    @IBAction func addJPQButtonAction(sender: NSButton)
    {
        // Since running the savePanel will hault the sender action from returning
        // we must prompt the save panel asyncronously
        DispatchQueue.main.async(execute: { () -> Void in
            self.addJPQPop.show(relativeTo: NSRect(x: 0, y: 0, width: 250, height: 160), of: self.addJPQLabel, preferredEdge: NSRectEdge.maxY)
        })
        return
    }
    
    var constList:Array<NSLayoutConstraint>?
    @IBAction func loadJPQActionButton(sender: NSButton)
    {
        addJPQButton.isEnabled = false
        loadJPQButton.isEnabled = false
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.openPanel!.begin(completionHandler: { (result:NSApplication.ModalResponse) -> Void in
                if result.rawValue == NSFileHandlingPanelOKButton
                {
                    DispatchQueue.global(qos: .userInitiated).async(execute: { () -> Void in
                        self.loadJPQFile(jpqFilePath: self.openPanel!.url! as NSURL)
                        DispatchQueue.main.sync(execute: { () -> Void in
                            self.addFileScrollViewIfNotSubViewedOfSelf()
                            self.addJPQButton.isEnabled = true
                            self.loadJPQButton.isEnabled = true
                            self.jpqModifierView.isHidden = true
                            self.fileModifierView.isHidden = false
                        })
                    })
                }
                else
                {
                    self.addJPQButton.isEnabled = true
                    self.loadJPQButton.isEnabled = true
                }
            })
        })
    }
    
    @IBAction func unloadJPQPressed(sender: NSButton)
    {
        self.loadedJPQFile = nil;
        self.jpqModifierView.isHidden = false
        self.fileModifierView.isHidden = true
        self.removeFileScrollViewIfNotSubViewedOfSelf()
    }
    
    func addConstraintForBottomSection(view: NSView) -> Array<NSLayoutConstraint>
    {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let bottom = NSLayoutConstraint(item: self.view, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: self.view, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: toolbarVisualEffectsView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
        let leading = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
        
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
    
    func addFileScrollViewIfNotSubViewedOfSelf()
    {
        if !fileOutlineScrollView.isDescendant(of: self.view)
        {
            fileOutlineScrollView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.view.addSubview(fileOutlineScrollView)
            self.constList = addConstraintForBottomSection(view: fileOutlineScrollView)
            
            var frame = view.window!.frame
            frame.size.height = 500
            view.window!.setFrame(frame, display: true, animate: true)
        }
    }
    
    func removeFileScrollViewIfNotSubViewedOfSelf()
    {
        if fileOutlineScrollView.isDescendant(of: self.view)
        {
            FileViewController.removeConstraintsFromView(view: self.view, withConstraints: self.constList!)
            
            fileOutlineScrollView.animator().removeFromSuperview()
            
            var frame = view.window!.frame
            frame.size.height = self.toolbarVisualEffectsView.frame.height
            view.window!.setFrame(frame, display: true, animate: true)
        }
    }
    
    func createJPQFilePrompt(maxFiles:UInt64, filePositionByteSize:UInt8)
    {
        addJPQButton.isEnabled = false
        loadJPQButton.isEnabled = false
        
        
        // Since running the savePanel will hault the sender action from returning
        // we must prompt the save panel asyncronously
        DispatchQueue.main.async(execute: { () -> Void in
            
            self.savePanel!.begin { (result: NSApplication.ModalResponse) -> Void in
                if result.rawValue == NSFileHandlingPanelOKButton
                {
                    if let fileLocation = self.savePanel?.url?.path
                    {
                        self.saveJPQFile(fileLocation: fileLocation, maxFiles: maxFiles, filePositionByteSize: filePositionByteSize, replace: false)
                    }
                    else
                    {
                        self.dispatchStandardAlert(title: "JPQFile Failed to Save!", body: "The file location you're attemping to save to is invalid aka nil.",
                            style: .warning)
                    }
                }
                self.addJPQButton.isEnabled = true
                self.loadJPQButton.isEnabled = true
            }
            
            //dispatch_async must return void
            return
        })
    }
    
    func loadJPQFile(jpqFilePath:NSURL)
    {
        let jpqFile = JPQLibSwiftBridge.loadJPQPackage(jpqFilePath.path!)
        if jpqFile != nil
        {
            self.loadedJPQFile = jpqFile
            var fileSize:UInt64 = 0
            let fileData:NSData = self.loadedJPQFile!.loadFile("/dufus/marcus/(jpqdir)", withFileSize:&fileSize)! as NSData
            
            let fileStuff:NSString = NSString(data: fileData as Data, encoding: String.Encoding.utf8.rawValue)!
            
            print("Size:\(fileSize)", terminator: "")
            print("StringLength:\(fileStuff.length)", terminator: "")
            print("Stuff:\(fileStuff)", terminator: "")
        }
    }
    
    func saveJPQFile(fileLocation:String, maxFiles:UInt64, filePositionByteSize:UInt8, replace:Bool = false) -> Void
    {
        let jpqFile = JPQLibSwiftBridge.createJPQPackage(fileLocation,
            withOverwriteFile: replace,
            withMaxNumberOfFiles: NSNumber(value: maxFiles),
            withVersion: nil,
            withFilePositionSizeInBytes: NSNumber(value: filePositionByteSize))
        if let jpqFile = jpqFile
        {
            if jpqFile.errorCode != 0
            {
                switch jpqFile.errorCode
                {
                case 1:
                    self.dispatchStandardAlert(title: "JPQFile Failed to Save!",
                        body: "An unknown error has occured that has prevented the JPQFile from saving.",
                        style: NSAlert.Style.warning)
                case 2:
                    let alert = NSAlert()
                    alert.addButton(withTitle: "Cancel")
                    alert.addButton(withTitle: "Overwrite File");
                    alert.messageText = "JPQFile Already Exists!"
                    alert.informativeText = "The JPQFile already exists!\rAre you sure you want to overwrite the file?\rThere is no going back!"
                    alert.alertStyle = NSAlert.Style.critical
                    alert.beginSheetModal(for: self.view.window!, completionHandler: { (NSModalResponse) -> Void in
                        if NSModalResponse == NSApplication.ModalResponse.alertSecondButtonReturn
                        {
                            self.saveJPQFile(fileLocation: fileLocation, maxFiles: maxFiles, filePositionByteSize: filePositionByteSize, replace: true)
                        }
                    })
                case 4:
                    self.dispatchStandardAlert(title: "JPQFile Failed to Save!",
                        body: "OS X has denied you write access to the location you've chosen!",
                        style: NSAlert.Style.warning)
                case 8:
                    self.dispatchStandardAlert(title: "JPQFile Failed to Save!",
                        body: "OS X has denied you read access to the location you've chosen!",
                        style: NSAlert.Style.warning)
                default:
                    break
                }
            }
            else
            {
                addJPQPop.close()
                self.jpqModifierView.isHidden = true
                self.fileModifierView.isHidden = false
                self.loadedJPQFile = jpqFile
                self.addFileScrollViewIfNotSubViewedOfSelf()
            }
        }
        else
        {
            self.dispatchStandardAlert(title: "JPQFile Failed to Save!",
                body: "An unknown error has occured that has prevented the file from saving. The JPQFile was returned as nil to the program.",
                style: .warning)
        }
    }
    
    func addFile(fileLocation:String, replace:Bool = false) -> Void
    {
        
    }
    
    func dispatchStandardAlert(title:String, body:String, style:NSAlert.Style)
    {
        let alert = NSAlert()
        alert.addButton(withTitle: "Continue")
        alert.messageText = title
        alert.informativeText = body
        alert.alertStyle = style
        alert.beginSheetModal(for: self.view.window!, completionHandler: { (NSModalResponse) -> Void in
            
        })
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}


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
    @IBOutlet weak var fileTableScrollView: FileScrollView!
    @IBOutlet weak var fileTableView: FileTableView!
    
    var savePanel:NSSavePanel?
    var loadedJPQFile:JPQFileSwiftBridge?
    var addJPQPop = NSPopover()
    var addJPQPopVC = AddJPQPopover(nibName: "AddJPQPopover", bundle: nil)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fileTableView.controller = self
        fileTableView.registerForDraggedTypes(NSArray(objects:  NSURLPboardType))
        
        savePanel = NSSavePanel()
        savePanel!.nameFieldLabel = "JPQ Name:"
        savePanel!.nameFieldStringValue = "file.JPQ"
        savePanel!.allowedFileTypes = ["JPQ"]
        savePanel!.allowsOtherFileTypes = false
        savePanel!.extensionHidden = false
        savePanel!.canCreateDirectories = true
        
        toolbarVisualEffectsView.state = NSVisualEffectState.FollowsWindowActiveState
        toolbarVisualEffectsView.material = NSVisualEffectMaterial.Titlebar
        toolbarVisualEffectsView.blendingMode = NSVisualEffectBlendingMode.BehindWindow
        
        addJPQPop.contentViewController = addJPQPopVC
        addJPQPop.behavior = NSPopoverBehavior.Semitransient
        addJPQPopVC.setContainer(self)
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addJPQButtonAction(sender: NSButton)
    {
        // Since running the savePanel will hault the sender action from returning
        // we must prompt the save panel asyncronously
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.addJPQPop.showRelativeToRect(NSRect(x: 0, y: 0, width: 250, height: 160), ofView: self.addJPQLabel, preferredEdge: NSMaxYEdge)
            })
        
        return;
        //Since this method is returning, nothing should be getting called after this return
        //however that's not the case. The button becomes disabled at sender.enabled= false
        sender.enabled = false
        
        loadJPQButton.enabled = false
        
        // Since running the savePanel will hault the sender action from returning
        // we must prompt the save panel asyncronously
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.savePanel!.beginWithCompletionHandler { (result: Int) -> Void in
                if result == NSFileHandlingPanelOKButton
                {
                    if let fileLocation = self.savePanel?.URL?.path
                    {
                        self.saveFile(fileLocation, replace: false)
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
    
    @IBAction func loadJPQActionButton(sender: NSButton)
    {
        
    }
    
    @IBAction func unloadJPQPressed(sender: NSButton)
    {
        self.loadedJPQFile = nil;
        self.jpqModifierView.hidden = false
        self.fileModifierView.hidden = true
    }
    
    func saveFile(fileLocation:String, replace:Bool = false) -> Void
    {
        var jpqFile = JPQLibSwiftBridge.CreateJPQPackage(fileLocation,
            withOverwriteFile: replace,
            withMaxNumberOfFiles: nil,
            withVersion: nil,
            withFilePositionSizeInBytes: nil)
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
                            self.saveFile(fileLocation, replace: true)
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
        alert.beginSheetModalForWindow(self.view.window!, modalDelegate: self, didEndSelector: nil, contextInfo: nil)
    }
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}


//
//  ViewController.swift
//  JPQUtility
//
//  Created by Jared Jones on 11/2/14.
//  Copyright (c) 2014 Uvora. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet var toolbarVisualEffectsView: NSVisualEffectView!
    @IBOutlet weak var addJPQSegmentButton: NSSegmentedControl!
    @IBOutlet weak var loadJPQSegmentButton: NSSegmentedControl!
    
    var savePanel:NSSavePanel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        // Do any additional setup after loading the view.
    }

    @IBAction func addJPQSegmentAction(sender: NSSegmentedControl) {
        
        sender.enabled = false
        
        // Since running the savePanel will hault the sender action from returning
        // we must prompt the save panel asyncronously
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.savePanel!.beginWithCompletionHandler { (result: Int) -> Void in
                
                if let fileLocation = self.savePanel?.URL?.path
                {
                    var jpqFile = JPQLibSwiftBridge.CreateJPQPackage(fileLocation,
                        withMaxNumberOfFiles: nil,
                        withVersion: nil,
                        withFilePositionSizeInBytes: nil)
                }
                else
                {
                    let alert = NSAlert()
                    alert.addButtonWithTitle("Continue")
                    alert.messageText = "File Saving Failed!"
                    alert.informativeText = "The file location you're attemping to save to is invalid aka nil."
                    alert.alertStyle = NSAlertStyle.WarningAlertStyle
                    alert.beginSheetModalForWindow(self.view.window!, modalDelegate: self, didEndSelector: nil, contextInfo: nil)
                }
                self.addJPQSegmentButton.enabled = true
            }
            
            //dispatch_async must return void
            return
        })
        
        
    }
    
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}


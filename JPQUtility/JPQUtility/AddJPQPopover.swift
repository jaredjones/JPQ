//
//  AddJPQPopover.swift
//  JPQUtility
//
//  Created by Jared Jones on 1/18/15.
//  Copyright (c) 2015 Uvora. All rights reserved.
//

import Cocoa

class AddJPQPopover: NSViewController, NSTextFieldDelegate
{
    @IBOutlet weak var maxNumberOfFilesTextField: NSTextField!
    @IBOutlet weak var filePositionByteSizeTextField: NSTextField!
    @IBOutlet weak var combinedStorageTextField: NSTextField!
    @IBOutlet weak var maxFilesStepper: NSStepper!
    @IBOutlet weak var filePositionStepper: NSStepper!
    
    weak var container:FileViewController?
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        maxNumberOfFilesTextField.delegate = self
        filePositionByteSizeTextField.delegate = self
        
        maxFilesStepper.integerValue = 1024
        filePositionStepper.integerValue = 4
        
        maxNumberOfFilesTextField.stringValue = String("\(maxFilesStepper.integerValue)")
        filePositionByteSizeTextField.stringValue = String("\(filePositionStepper.integerValue)")
        // Do view setup here.
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    @IBAction func cancelJPQPopover(sender: AnyObject)
    {
        container!.addJPQPop.close()
    }
    @IBAction func createJPQButton(sender: NSButton)
    {
        let x = self.maxFilesStepper.integerValue
        let y = self.filePositionStepper.integerValue
        container!.createJPQFilePrompt(x, filePositionByteSize: y)
    }
    
    func setContainer(cont:FileViewController)
    {
        self.container = cont
    }
    
    @IBAction func stepperPressed(sender: NSStepper)
    {
        if sender == self.maxFilesStepper
        {
            self.maxNumberOfFilesTextField.stringValue = self.maxFilesStepper.stringValue
        }
        if sender == self.filePositionStepper
        {
            var x = self.filePositionStepper.integerValue
            let y = self.filePositionByteSizeTextField.integerValue
            
            if x < y
            {
                x = y / 2
            }
            else if x > y && x < 8
            {
                x = y * 2
            }
            else
            {
                x = y
            }
            
            self.filePositionStepper.integerValue = x
            self.filePositionByteSizeTextField.stringValue = ("\(x)")
        }
    }
    //Allows only numbers in Textfield
    var lastLength:Int = 0
    override func controlTextDidChange(obj: NSNotification)
    {
        let txtField:NSTextField = obj.object as NSTextField
        let len = txtField.stringValue.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        if len == 0
        {
            return
        }
        var str:NSString = txtField.stringValue
        
        //Check for non-ascii character and remove it
        if (len - lastLength) > 1
        {
            txtField.stringValue = str.substringToIndex(len - (len - lastLength))
            return
        }
        
        //Grab character and strip it if it's not a number
        let chr = str.characterAtIndex(len - 1)
        if chr < 48 || chr > 57
        {
            str = str.substringToIndex(len - 1)
            txtField.stringValue = str
        }
        lastLength = txtField.stringValue.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        
        if obj == maxNumberOfFilesTextField
        {
            self.maxFilesStepper.integerValue = txtField.integerValue
            self.stepperPressed(self.maxFilesStepper)
        }
    }
    
    override func controlTextDidBeginEditing(obj: NSNotification)
    {
        let txtField:NSTextField = obj.object as NSTextField
        lastLength = txtField.stringValue.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
    }
}

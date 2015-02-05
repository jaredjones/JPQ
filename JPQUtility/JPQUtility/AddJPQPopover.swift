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
    @IBOutlet weak var combinedStorageLabel: NSTextField!
    @IBOutlet weak var fileSizeLabel: NSTextField!
    @IBOutlet weak var maxFilesStepper: NSStepper!
    @IBOutlet weak var filePositionStepper: NSStepper!
    
    var maxNumberOfFiles:UInt64 = 1024
    var filePositionByteSize:UInt8 = 4
    
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
        
        maxFilesStepper.integerValue = Int(maxNumberOfFiles)
        filePositionStepper.integerValue = Int(filePositionByteSize)
        
        maxNumberOfFilesTextField.stringValue = String("\(maxNumberOfFiles)")
        filePositionByteSizeTextField.stringValue = String("\(filePositionByteSize)")
        
        updateFileSizeLabel()
        // Do view setup here.
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    func setContainer(cont:FileViewController)
    {
        self.container = cont
    }
    
    func updateFileSizeLabel()
    {
        var fileIndexSize = 4
        let headerSize = 49
        if maxNumberOfFiles >= UInt64(powf(2, 31))
        {
            fileIndexSize = 8
        }
        let estimatedFileSize:UInt64 = headerSize + maxNumberOfFiles * (4 + UInt64(filePositionByteSize))
        fileSizeLabel.stringValue = "The estimated file size will be \(estimatedFileSize) bytes."
    }
    
    @IBAction func cancelJPQPopover(sender: AnyObject)
    {
        container!.addJPQPop.close()
    }
    
    @IBAction func createJPQButton(sender: NSButton)
    {
        let x = maxNumberOfFiles
        let y = filePositionByteSize
        container!.createJPQFilePrompt(x, filePositionByteSize: y)
    }
    
    @IBAction func stepperPressed(sender: NSStepper)
    {
        if sender == self.maxFilesStepper
        {
            self.maxNumberOfFiles = UInt64(maxFilesStepper.integerValue)
            self.maxNumberOfFilesTextField.stringValue = ("\(self.maxNumberOfFiles)")
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
            self.filePositionByteSize = UInt8(x)
            self.filePositionByteSizeTextField.stringValue = ("\(filePositionByteSize)")
        }
        updateFileSizeLabel()
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
        
        if txtField == maxNumberOfFilesTextField
        {
            if Double(txtField.doubleValue) >= (pow(2, 53) + 1.0)
            {
                txtField.stringValue = "\(UInt64(pow(2,53) + 1.0))"
            }
            self.maxFilesStepper.integerValue = txtField.integerValue
            self.maxNumberOfFiles = UInt64(txtField.integerValue)
            self.stepperPressed(self.maxFilesStepper)
            updateFileSizeLabel()
        }
    }
    
    override func controlTextDidBeginEditing(obj: NSNotification)
    {
        let txtField:NSTextField = obj.object as NSTextField
        lastLength = txtField.stringValue.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
    }
}

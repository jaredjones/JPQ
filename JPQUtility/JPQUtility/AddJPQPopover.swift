//
//  AddJPQPopover.swift
//  JPQUtility
//
//  Created by Jared Jones on 1/18/15.
//  Copyright (c) 2015 Uvora. All rights reserved.
//

import Cocoa

extension Double
{
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self)
    }
}

class AddJPQPopover: NSViewController, NSTextFieldDelegate
{
    @IBOutlet weak var maxNumberOfFilesTextField: NSTextField!
    @IBOutlet weak var filePositionByteSizeTextField: NSTextField!
    @IBOutlet weak var combinedStorageLabel: NSTextField!
    @IBOutlet weak var fileSizeLabel: NSTextField!
    @IBOutlet weak var maxFilesStepper: NSStepper!
    @IBOutlet weak var filePositionStepper: NSStepper!
    @IBOutlet weak var baseTwoCheckBox: NSButton!
    
    var maxNumberOfFiles:UInt64 = 1024
    var filePositionByteSize:UInt8 = 4
    var useBaseTwo:Bool = true
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
        
        baseTwoCheckBox.state = Int(useBaseTwo)
        
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
        var fileIndexSize:UInt64 = 4
        let headerSize:UInt64 = 49
        if maxNumberOfFiles >= UInt64(powf(2, 31))
        {
            fileIndexSize = 8
        }
        let estimatedFileSize:UInt64 = headerSize + maxNumberOfFiles * (4 + UInt64(filePositionByteSize))
        
        var abreviatedSizeBig:Swift.Float80 = Swift.Float80(estimatedFileSize)
        
        var counter:Int = 0
        var byteString:String
        var format = ".3"
        
        var dividend:Swift.Float80 = 1024.0
        if (useBaseTwo){
            dividend = 1024.0
        }else{
            dividend = 1000.0
        }
        
        while abreviatedSizeBig > dividend
        {
            abreviatedSizeBig /= dividend
            counter++
        }
        let abreviatedSize:Double = Double(abreviatedSizeBig)
        
        if (useBaseTwo)
        {
            switch counter
            {
            case 0:
                byteString = "\(abreviatedSize) bytes"
            case 1:
                byteString = "\(abreviatedSize.format(format))KiBs"
            case 2:
                byteString = "\(abreviatedSize.format(format))MiBs"
            case 3:
                byteString = "\(abreviatedSize.format(format))GiBs"
            case 4:
                byteString = "\(abreviatedSize.format(format))TiBs"
            case 5:
                byteString = "\(abreviatedSize.format(format))PiBs"
            case 6:
                byteString = "\(abreviatedSize.format(format))EiBs"
            case 7:
                byteString = "\(abreviatedSize.format(format))ZiBs"
            case 8:
                byteString = "\(abreviatedSize.format(format))YiBs"
            default:
                byteString = "\(abreviatedSize.format(format)) bytes"
            }
        }
        else
        {
            switch counter
            {
            case 0:
                byteString = "\(abreviatedSize) bytes"
            case 1:
                byteString = "\(abreviatedSize.format(format))KBs"
            case 2:
                byteString = "\(abreviatedSize.format(format))MBs"
            case 3:
                byteString = "\(abreviatedSize.format(format))GBs"
            case 4:
                byteString = "\(abreviatedSize.format(format))TBs"
            case 5:
                byteString = "\(abreviatedSize.format(format))PBs"
            case 6:
                byteString = "\(abreviatedSize.format(format))EBs"
            case 7:
                byteString = "\(abreviatedSize.format(format))ZBs"
            case 8:
                byteString = "\(abreviatedSize.format(format))YBs"
            default:
                byteString = "\(abreviatedSize.format(format)) bytes"
            }
        }
        if counter == 0
        {
            fileSizeLabel.stringValue = "JPQ Size: \(estimatedFileSize) bytes."
        }
        else
        {
            fileSizeLabel.stringValue = "JPQ Size: \(estimatedFileSize) bytes (\(byteString))."
        }
    }
    
    @IBAction func baseChangePressed(sender: NSButton) {
        if (sender.state == 0)
        {
            useBaseTwo = false
        }
        else
        {
            useBaseTwo = true
        }
        updateFileSizeLabel()
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

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
        return NSString(format: "%\(f)f" as NSString, self) as String
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
    weak var holder:FileViewController?
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
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
        
        baseTwoCheckBox.state = NSControl.StateValue(rawValue: useBaseTwo ? 1 : 0)
        
        updateFileSizeLabel()
        // Do view setup here.
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    func updateFileSizeLabel()
    {
        let headerSize:UInt64 = UInt64(JPQLibSwiftBridge.getJPQHeaderSize())
        
        var spaceForFiles:UInt64
        if ( filePositionByteSize * 8 == 64)
        {
            spaceForFiles = UInt64.max
        }
        else
        {
            spaceForFiles = UInt64(pow(2,Float(filePositionByteSize * 8)))
        }
        
        spaceForFiles -= headerSize
        
        /*var fileIndexSize:UInt64 = 4
        if maxNumberOfFiles >= UInt64(powf(2, 31))
        {
            fileIndexSize = 8
        }*/
        
        var dividend:Swift.Float80
        if (useBaseTwo){
            dividend = 1024.0
        }else{
            dividend = 1000.0
        }
        
        let estimatedMaxFileSize:UInt64 = headerSize + maxNumberOfFiles * (4 + UInt64(filePositionByteSize))
        var abbreviatedMaxFilesBig:Swift.Float80 = Swift.Float80(estimatedMaxFileSize)
        
        var counterMaxFiles:Int = 0
        while abbreviatedMaxFilesBig > dividend
        {
            abbreviatedMaxFilesBig /= dividend
            counterMaxFiles += 1
        }
        
        var abbreviatedSpaceFilesBig:Swift.Float80 = Swift.Float80(spaceForFiles)
        var counterSpaceFiles:Int = 0
        while abbreviatedSpaceFilesBig > dividend
        {
            abbreviatedSpaceFilesBig /= dividend
            counterSpaceFiles += 1
        }
        
        let maxFileByteString = convertToAbbreviatedForm(counter: counterMaxFiles, size: Double(abbreviatedMaxFilesBig))
        
        if counterMaxFiles == 0
        {
            fileSizeLabel.stringValue = "JPQ Size: \(estimatedMaxFileSize) bytes."
        }
        else
        {
            fileSizeLabel.stringValue = "JPQ Size: \(estimatedMaxFileSize) bytes (\(maxFileByteString))."
        }
        
        let combinedStorageByteString = convertToAbbreviatedForm(counter: counterSpaceFiles, size: Double(abbreviatedSpaceFilesBig))
        
        if counterSpaceFiles == 0
        {
            combinedStorageLabel.stringValue = "Max Storage: \(spaceForFiles) bytes."
        }
        else
        {
            combinedStorageLabel.stringValue = "Max Storage: \(spaceForFiles) bytes (\(combinedStorageByteString))."
        }
    }
    
    func convertToAbbreviatedForm(counter:Int, size:Double) -> String
    {
        var byteString:String
        let format = ".3"
        if (useBaseTwo)
        {
            switch counter
            {
            case 0:
                byteString = "\(size) bytes"
            case 1:
                byteString = "\(size.format(f: format))KiBs"
            case 2:
                byteString = "\(size.format(f: format))MiBs"
            case 3:
                byteString = "\(size.format(f: format))GiBs"
            case 4:
                byteString = "\(size.format(f: format))TiBs"
            case 5:
                byteString = "\(size.format(f: format))PiBs"
            case 6:
                byteString = "\(size.format(f: format))EiBs"
            case 7:
                byteString = "\(size.format(f: format))ZiBs"
            case 8:
                byteString = "\(size.format(f: format))YiBs"
            default:
                byteString = "\(size.format(f: format)) bytes"
            }
        }
        else
        {
            switch counter
            {
            case 0:
                byteString = "\(size) bytes"
            case 1:
                byteString = "\(size.format(f: format))KBs"
            case 2:
                byteString = "\(size.format(f: format))MBs"
            case 3:
                byteString = "\(size.format(f: format))GBs"
            case 4:
                byteString = "\(size.format(f: format))TBs"
            case 5:
                byteString = "\(size.format(f: format))PBs"
            case 6:
                byteString = "\(size.format(f: format))EBs"
            case 7:
                byteString = "\(size.format(f: format))ZBs"
            case 8:
                byteString = "\(size.format(f: format))YBs"
            default:
                byteString = "\(size.format(f: format)) bytes"
            }
        }
        return byteString;
    }
    
    @IBAction func baseChangePressed(sender: NSButton) {
        if (sender.state.rawValue == 0)
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
        holder!.addJPQPop.close()
    }
    
    @IBAction func createJPQButton(sender: NSButton)
    {
        let x = maxNumberOfFiles
        let y = filePositionByteSize
        holder!.createJPQFilePrompt(maxFiles: x, filePositionByteSize: y)
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
    override func controlTextDidChange(_ notification: Notification)
    {
        let txtField:NSTextField = notification.object as! NSTextField
        let len = txtField.stringValue.lengthOfBytes(using: String.Encoding.utf8)
        if len == 0
        {
            return
        }
        var str:NSString = txtField.stringValue as NSString
        
        //Check for non-ascii character and remove it
        if (len - lastLength) > 1
        {
            txtField.stringValue = str.substring(to: len - (len - lastLength))
            return
        }
        
        //Grab character and strip it if it's not a number
        let chr = str.character(at: len - 1)
        if chr < 48 || chr > 57
        {
            str = str.substring(to: len - 1) as NSString
            txtField.stringValue = str as String
        }
        lastLength = txtField.stringValue.lengthOfBytes(using: String.Encoding.utf8)
        
        if txtField == maxNumberOfFilesTextField
        {
            if Double(txtField.doubleValue) >= (pow(2, 53) + 1.0)
            {
                txtField.stringValue = "\(UInt64(pow(2,53) + 1.0))"
            }
            self.maxFilesStepper.integerValue = txtField.integerValue
            self.maxNumberOfFiles = UInt64(txtField.integerValue)
            self.stepperPressed(sender: self.maxFilesStepper)
            updateFileSizeLabel()
        }
    }
    
    override func controlTextDidBeginEditing(_ notification: Notification)
    {
        let txtField:NSTextField = notification.object as! NSTextField
        lastLength = txtField.stringValue.lengthOfBytes(using: String.Encoding.utf8)
    }
}

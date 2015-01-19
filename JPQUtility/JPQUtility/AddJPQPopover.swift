//
//  AddJPQPopover.swift
//  JPQUtility
//
//  Created by Jared Jones on 1/18/15.
//  Copyright (c) 2015 Uvora. All rights reserved.
//

import Cocoa

class AddJPQPopover: NSViewController
{
    @IBOutlet weak var maxNumberOfFilesTextField: NSTextField!
    @IBOutlet weak var filePositionByteSizeTextField: NSTextField!
    @IBOutlet weak var combinedStorageTextField: NSTextField!
    
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
    }
    
    func setContainer(cont:FileViewController)
    {
        self.container = cont
    }
}

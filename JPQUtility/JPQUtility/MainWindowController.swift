//
//  MainWindowController.swift
//  JPQUtility
//
//  Created by Jared Jones on 11/15/14.
//  Copyright (c) 2014 Uvora. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

    override func awakeFromNib() {
        self.window!.styleMask = [self.window!.styleMask , NSWindow.StyleMask.fullSizeContentView]
        self.window!.titlebarAppearsTransparent = true
    }
    override func windowDidLoad() {
        super.windowDidLoad()
    }

}

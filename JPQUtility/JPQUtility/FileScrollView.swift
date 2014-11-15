//
//  FileScrollView.swift
//  JPQUtility
//
//  Created by Jared Jones on 11/14/14.
//  Copyright (c) 2014 Uvora. All rights reserved.
//

import Cocoa

class FileScrollView: NSScrollView {

    let line = TopLineView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(line)
    }
    
    override func viewWillDraw() {
        line.frame = CGRectMake(0, 0, self.frame.width, 1)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        // Drawing code here.
    }
}

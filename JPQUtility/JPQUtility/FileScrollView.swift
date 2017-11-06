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
        
        line.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 1)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
}

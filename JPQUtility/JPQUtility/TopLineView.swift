//
//  BottomViewContainer.swift
//  JPQUtility
//
//  Created by Jared Jones on 11/14/14.
//  Copyright (c) 2014 Uvora. All rights reserved.
//

import Cocoa

class TopLineView: NSView
{
    override func drawRect(dirtyRect: NSRect)
    {
        super.drawRect(dirtyRect)
        self.drawBorder(dirtyRect)
    }
    
    func drawBorder(rect:NSRect)
    {
        if (rect.size.height < self.bounds.size.height)
        {
            return;
        }
    
        let line:NSBezierPath = NSBezierPath()
        line.moveToPoint(NSMakePoint(0, rect.height))
        line.lineToPoint(NSMakePoint(rect.width, rect.height))
        
        line.lineWidth = 1;
        NSColor(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 1).set()
        
        line.stroke()
    }
    
}

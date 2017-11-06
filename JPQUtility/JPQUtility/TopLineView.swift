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
    override func draw(_ dirtyRect: NSRect)
    {
        super.draw(dirtyRect)
        self.drawBorder(rect: dirtyRect)
    }
    
    func drawBorder(rect:NSRect)
    {
        if (rect.size.height < self.bounds.size.height)
        {
            return;
        }
    
        let line:NSBezierPath = NSBezierPath()
        line.move(to: NSMakePoint(0, rect.height))
        line.line(to: NSMakePoint(rect.width, rect.height))
        
        line.lineWidth = 1;
        NSColor(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 1).set()
        
        line.stroke()
    }
    
}

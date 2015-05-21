//
//  FileOutlineView.swift
//  JPQUtility
//
//  Created by Jared Jones on 1/4/15.
//  Copyright (c) 2015 Uvora. All rights reserved.
//

import Cocoa

class FileOutlineView: NSOutlineView/*, NSDraggingDestination*/
{
    weak var controller:FileViewController?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    convenience init()
    {
        self.init(frame: CGRectMake(0, 0, 0, 0))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        // Drawing code here.
    }
    
    
    /*
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.Copy
    }
    override func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.Copy
    }
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        let pboard = sender.draggingPasteboard()
        let sourceDragMask = sender.draggingSourceOperationMask()
        
        let str:NSArray = pboard.types!
        if str.containsObject(NSURLPboardType)
        {
            let fileURL = NSURL(fromPasteboard: pboard)
            let fileName = fileURL?.path
            //controller?.addFile(fileName!, replace: false)
            //(self.delegate() as FileTableDelegateAndData).tableData.append(Dictionary(dictionaryLiteral: ("filename", fileName!)))
            //self.reloadData()
        }
        
        return true
    }
    
    */
    
}

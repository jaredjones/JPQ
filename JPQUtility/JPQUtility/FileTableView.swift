//
//  FileTableView.swift
//  JPQUtility
//
//  Created by Jared Jones on 1/4/15.
//  Copyright (c) 2015 Uvora. All rights reserved.
//

import Cocoa

class FileTableView: NSTableView, NSDraggingDestination
{
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
            (self.delegate() as FileTableDelegateAndData).tableData.append(Dictionary(dictionaryLiteral: ("filename", fileName!)))
            self.reloadData()
        }
        
        return true
    }
}

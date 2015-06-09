//
//  FileTableDelegateAndData.swift
//  JPQUtility
//
//  Created by Jared Jones on 1/4/15.
//  Copyright (c) 2015 Uvora. All rights reserved.
//

import Cocoa

class FileTableDelegateAndData: NSObject, NSTableViewDelegate, NSTableViewDataSource
{
    var tableData: [Dictionary<String, String>] = []
    
    override init() {
        super.init()
        tableData.append(["filename":"Steve Jobs", "datemodified":"01/01/1984", "size":"0"])
    }
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return tableData.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return tableData[row][tableColumn!.identifier]
    }
    
    func tableView(tableView: NSTableView, willDisplayCell cell: AnyObject, forTableColumn tableColumn: NSTableColumn?, row: Int) {
        //let fieldCell = cell as! NSTextFieldCell
        
    }
}
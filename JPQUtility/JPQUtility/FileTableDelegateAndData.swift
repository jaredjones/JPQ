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
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let row: Dictionary<String, String> = tableData[row]
        return row.index(forKey: tableColumn!.identifier.rawValue) as AnyObject
    }
    
    func tableView(_ tableView: NSTableView, willDisplayCell cell: Any, for tableColumn: NSTableColumn?, row: Int) {
        //let fieldCell = cell as! NSTextFieldCell
        
    }
}

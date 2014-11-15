//
//  ViewController.swift
//  JPQUtility
//
//  Created by Jared Jones on 11/2/14.
//  Copyright (c) 2014 Uvora. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet var toolbarVisualEffectsView: NSVisualEffectView!
    @IBOutlet weak var fileScrollView: FileScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        toolbarVisualEffectsView.state = NSVisualEffectState.FollowsWindowActiveState
        toolbarVisualEffectsView.material = NSVisualEffectMaterial.Titlebar
        toolbarVisualEffectsView.blendingMode = NSVisualEffectBlendingMode.BehindWindow
        
        var asdf = JPQLibCPlusPlusBridge()
        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}


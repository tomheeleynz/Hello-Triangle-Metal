//
//  ViewController.swift
//  MetalTriangle
//
//  Created by Thomas Heeley on 10/07/21.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {
    var renderer : Renderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let metalView = view as? MTKView else {
            fatalError("Metal View not set up in storyboard")
        }
        
        renderer = Renderer(metalView: metalView)
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}


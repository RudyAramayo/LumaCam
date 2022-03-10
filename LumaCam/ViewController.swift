//
//  ViewController.swift
//  LumaCam
//
//  Created by Rob Makina on 3/10/22.
//

import UIKit
import RealityKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let arCoachScene = try! LumaLabsCapture.loadARCoachScene()
        arView.scene.anchors.append(arCoachScene)
    }
}

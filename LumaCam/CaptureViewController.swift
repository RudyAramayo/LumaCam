//
//  CaptureViewController.swift
//  LumaCam
//
//  Created by Rob Makina on 3/10/22.
//
import Foundation
import UIKit
import ARKit
import RealityKit

enum AppState: Int16 {
    case DetectSurface  // Scan surface (Plane Detection On)
    case PointAtSurface // Point at surface to see focus point (Plane Detection Off)
    case TapToStart     // Focus point visible on surface, tap to start
    case Started
}

class CaptureViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    @IBOutlet var coachingView2D: UIView!
    @IBOutlet var coachingView2D_2: UIView!

    
    var trackingStatus: String = ""
    var statusMessage: String = ""
    var appState: AppState = .DetectSurface
    var focusPoint:CGPoint!
    var focusNode: SCNNode!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCoachingOverlay()
        
        self.addCoachingOverlay()
        self.initFocusNode()
    }
    
    func resetARSession() {
        let config = arView.session.configuration as!
        ARWorldTrackingConfiguration
        config.planeDetection = .horizontal
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func initARCoachScene() {
        let arCoachScene = try! LumaLabsCapture.loadARCoachScene()
        arView.scene.anchors.append(arCoachScene)
    }
    
    // MARK: - IB Actions
    @IBAction func resetButtonPressed(_ sender: Any) {
        self.resetApp()
    }
    
    @IBAction func tapGestureHandler(_ sender: Any) {
        guard appState == .TapToStart else { return }
        
        //TODO: HideFocustNode and show the capture reticle
        appState = .Started
    }
    
    @IBAction func beginARDemoScene() {
        let arCoachScene = try! LumaLabsCapture.loadARCoachScene()
        arView.scene.anchors.append(arCoachScene)
    }
    
    @IBAction func beginCaptureScene() {
        let arCoachScene = try! LumaLabsCapture.loadARCoachScene()
        arView.scene.anchors.append(arCoachScene)
    }
    
}


// MARK: - App Management

extension CaptureViewController {
    
    func startApp() {
        DispatchQueue.main.async {
            //self.arPortNode.isHidden = true
            //self.focusNode.isHidden = true
            self.appState = .DetectSurface
        }
    }
    
    func resetApp() {
        DispatchQueue.main.async {
            //self.arPortNode.isHidden = true
            //self.resetARSession()
            self.appState = .DetectSurface
        }
    }
}

//MARK: ARCoachingOverlay

extension CaptureViewController: ARCoachingOverlayViewDelegate {
    func addCoachingOverlay() {

// How does this overlay mix with the reality kit arview? not sure yet...left this in for analysis
//        let coachingOverlay = ARCoachingOverlayView()
//        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(coachingOverlay)
//        NSLayoutConstraint.activate([
//            coachingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            coachingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            coachingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
//            coachingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//        coachingOverlay.goal = .horizontalPlane
//        coachingOverlay.session = arView.session
//        coachingOverlay.delegate = self
        
        self.coachingView2D_2.alpha = 0.0
        //Show our 2D directions for 4 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            UIView.animate(withDuration: 0.33) {
                self.coachingView2D.alpha = 0.0
            } completion: { didComplete in
                self.coachingView2D.removeFromSuperview()
                self.showSecondCoachingView()
            }
        }
    }
    
    func showSecondCoachingView() {
        UIView.animate(withDuration: 0.33) {
            self.coachingView2D_2.alpha = 1.0
        } completion: { didComplete in
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                UIView.animate(withDuration: 0.33) {
                    self.coachingView2D_2.alpha = 0.0
                }
            }
        }
    }
    
    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
    }
    
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        self.startApp()
    }
    
    func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
        self.resetApp()
    }
    
    func begin2DARCoachingInstructions() {
        //Run this after we show the instructions
        //beginCaptureScene()
    }
}

extension CaptureViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        8
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
        case 0:
            return "TIME-LAPSE"
        case 1:
            return "SLO-MO"
        case 2:
            return "3D CAPTURE"
        case 3:
            return "VIDEO"
        case 4:
            return "PHOTO"
        case 5:
            return "PORTRAIT"
        case 6:
            return "SQUARE"
        case 7:
            return "PANO"
        default:
            return ""
        }
    }
}

// MARK: - Focus Node Management

extension CaptureViewController {
    @objc
    func orientationChanged() {
        focusPoint = CGPoint(x: view.center.x, y: view.center.y  + view.center.y * 0.1)
    }
    
    func initFocusNode() {
        //TODO: add the focus reticle scene to the experience and load it here as the focus node
        let arCoachScene = try! LumaLabsCapture.loadARCoachScene()
        arView.scene.anchors.append(arCoachScene)
        
        focusPoint = CGPoint(x: view.center.x, y: view.center.y + view.center.y * 0.1)
        NotificationCenter.default.addObserver(self, selector: #selector(CaptureViewController.orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        
    }
}

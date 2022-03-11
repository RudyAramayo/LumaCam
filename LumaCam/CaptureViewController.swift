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
    var appState: AppState = .TapToStart
    var focusPoint:CGPoint!
    var focusNode: LumaLabsCapture.ARReticle?
    var cameraAnchor: AnchorEntity?
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //show coaching overlay on first run
        self.addCoachingOverlay()
        self.initFocusNode()
        self.initRawFeatureParticles()
        
        self.arView.gestureRecognizers?.append(UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler(_:))))
    }
    
    func initRawFeatureParticles() {
        // In here we take rawFeaturePoints from current arframe and draw a
        // particle node on ever 100-1000th instance. Add that particle to
        // the particle system for nodes and make it fly up like a magical fire
        // under the object This function is a placeholder reminder to do this.
        //TODO:
        //Step1: tap and print out the rawFeaturePoints of an ARFrame
        //Step2: filter by points that are above our horizontal plane
        //Step3: add a particle node every 100-1000th feature point so we get a
        //       sparse fire from the particles, akin to magic.
    }
    
    func postCaptureRawFeatureParticles() {
        // After a successful capture make sure to take the rawFeaturePoints and
        // have them fly into the screen and onto the preview box so that it looks
        // like you captured the object in that preview window
        
        //TODO: animate particles nodes engine to fly into the preview box.
    }
    
    func resetARSession() {
        let config = arView.session.configuration as!
        ARWorldTrackingConfiguration
        config.planeDetection = .horizontal
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        initFocusNode()
    }
    
    // MARK: - IB Actions
    @IBAction func resetButtonPressed(_ sender: Any) {
        self.resetApp()
    }
    
    @objc func tapGestureHandler(_ sender: UITapGestureRecognizer) {
        let tapLocation:CGPoint = sender.location(in: arView)
        guard appState == .TapToStart else { return }
        guard let query = arView.makeRaycastQuery(from: tapLocation, allowing: .existingPlaneInfinite, alignment: .horizontal) else { return }
        guard let raycastResult = arView.session.raycast(query).first else { return }

        let anchor = AnchorEntity(world: raycastResult.worldTransform)
        let captureScene = try! LumaLabsCapture.loadCaptureScene()
        anchor.addChild(captureScene)
        
        self.arView.scene.anchors.append(anchor)
        //TODO: Perform raycast and set an anchor up with our capture
        //TODO: HideFocusNode and show the capture reticle
        //appState = .Started
        focusNode?.removeFromParent()
        cameraAnchor?.removeFromParent()
        cameraAnchor = nil
        focusNode = nil
    }
    
    func hideCoachView() {
        UIView.animate(withDuration: 0.33) { [weak self] in
            self?.coachingView2D_2.alpha = 0.0
        } completion: { [weak self] didFinish in
            self?.coachingView2D_2.removeFromSuperview()
        }
    }
    
    var arCoachScene: LumaLabsCapture.ARCoachScene?
    var captureScene: LumaLabsCapture.CaptureScene?
    
    @IBAction func beginARDemoScene() {
        hideCoachView()
        arCoachScene = try! LumaLabsCapture.loadARCoachScene()
        if let arCoachScene = arCoachScene {
            arView.scene.anchors.append(arCoachScene)
            //Initialize Actions
            arCoachScene.actions.aRDemoComplete.onAction = handleARDemoCompletedAction(_:)
        }
    }
    
    @IBAction func beginCaptureScene() {
        hideCoachView()
        captureScene = try! LumaLabsCapture.loadCaptureScene()
        if let captureScene = captureScene {
            arView.scene.anchors.append(captureScene)
            //Initialize Actions
            captureScene.actions.takePhoto.onAction = handleTakePhotoAction(_:)
        }
    }
    
    func handleARDemoCompletedAction(_ entity: Entity?) {
        guard let entity = entity else { return }
        //This is just a convenience method to notify we have completed...
        print("handleARDemoCompletedAction \(entity)")
    }
    
    func handleTakePhotoAction(_ entity: Entity?) {
        guard let entity = entity else { return }
        //Step1: check entity orientation relative to the origin, does the image seem to be pointing at the object
        //Step2: check if we are too close, show error UI if this is true
        //Step3: check if we are too far, show error UI if this is true
        //Step4: play a sound on the programmatic end only if the image was
        //       successful? sending a notification back to reality engine needs
        //       us to make 40 individual notification triggers for each mark
        //       that is later successfully removed. We can save this for when
        //       you choose to proceed further.
        // For now we just allow the reality file to mark the image as take successfully
        print("didTakePhotoAcrtion \(entity)")
    }
}


// MARK: - App State Management

extension CaptureViewController {
    
    func startApp() {
        DispatchQueue.main.async { [weak self] in
            //TODO: sync content/focus node
            //Step1: Hide ContentNode
            //Step2: Hide focusNode
            self?.appState = .TapToStart
        }
    }
    
    func resetApp() {
        DispatchQueue.main.async { [weak self] in
            //TODO: sync content/focus node
            //Step1: Hide ContentNode
            //Step2: reset ARSession
            self?.appState = .TapToStart
            self?.arView.scene.anchors.removeAll()
        }
    }
}

//MARK: - ARCoachingOverlay

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
            UIView.animate(withDuration: 0.33) { [weak self] in
                self?.coachingView2D.alpha = 0.0
            } completion: { [weak self] didComplete in
                self?.coachingView2D.removeFromSuperview()
                self?.showSecondCoachingView()
            }
        }
    }
    
    func showSecondCoachingView() {
        UIView.animate(withDuration: 0.33) { [weak self] in
            self?.coachingView2D_2.alpha = 1.0
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
}

// MARK: - Focus Node Management

extension CaptureViewController {
    @objc
    func orientationChanged() {
        focusPoint = CGPoint(x: view.center.x, y: view.center.y  + view.center.y * 0.1)
    }
    
    func initFocusNode() {
        //TODO: add the focus reticle scene to the experience and load it here as the focus node
        focusNode = try! LumaLabsCapture.loadARReticle()
        cameraAnchor = AnchorEntity(.camera)
        if let cameraAnchor = cameraAnchor {
            focusNode?.setParent(cameraAnchor)
            arView.scene.anchors.append(cameraAnchor)
            
            focusPoint = CGPoint(x: view.center.x, y: view.center.y + view.center.y * 0.1)
            NotificationCenter.default.addObserver(self, selector: #selector(CaptureViewController.orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        }
    }
}

// MARK: - UIPickerViewDelegate/Datasource

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

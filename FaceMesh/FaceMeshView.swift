//
//  FaceMeshViewController.swift
//  FaceMesh
//
//  Created by MaxMobile Software on 21/5/24.
//  Copyright © 2024 AppCoda. All rights reserved.
//

import Foundation
import SwiftUI
import ARKit
import ARVideoKit

struct FaceMeshView: UIViewControllerRepresentable {
    
    var recordViewModel: RecordViewModel
    
    func makeUIViewController(context: Context) -> ViewController {
        
        let coordinator = context.coordinator
        let viewController = ViewController(coordinator: coordinator, recordViewModel: recordViewModel)
        coordinator.viewController = viewController
//        DispatchQueue.main.async {
//            recordViewModel.recordAR = RecordAR(ARSceneKit: viewController.sceneView)
//            recordViewModel.recordAR?.contentMode = .aspectFill
//            recordViewModel.recordAR?.enableAudio = false
//            recordViewModel.recordAR?.delegate = coordinator
//        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(faceMeshView: self)
    }
}

// MARK: ViewController
extension FaceMeshView {
    final class ViewController: UIViewController {
        var coordinator: Coordinator
        
        var sceneView: ARSCNView = ARSCNView()
        var recordViewModel: RecordViewModel
        
        init(coordinator: Coordinator, recordViewModel: RecordViewModel) {
            self.coordinator = coordinator
            self.recordViewModel = recordViewModel
            sceneView.delegate = coordinator
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("In no way is this class related to an interface builder file.")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            sceneView.frame = view.bounds
            sceneView.delegate = coordinator
            sceneView.showsStatistics = true
            
            recordViewModel.recordAR = RecordAR(ARSceneKit: sceneView)
            recordViewModel.recordAR?.contentMode = .aspectFill
            recordViewModel.recordAR?.enableAudio = false
            recordViewModel.recordAR?.delegate = coordinator
            
            guard ARFaceTrackingConfiguration.isSupported else {
                print("Face tracking is not supported on this device")
                return
            }
            
            view.addSubview(sceneView)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            let configuration = ARFaceTrackingConfiguration()
            sceneView.session.run(configuration)
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            sceneView.session.pause()
        }
    }
}

// MARK: Coordinator
extension FaceMeshView {
    class Coordinator: NSObject, ARSCNViewDelegate, RecordARDelegate {
        var faceMeshView: FaceMeshView
        var viewController: ViewController?
        
        var stepRerender: Int = 0
        var index: Int = 0
        
        init(faceMeshView: FaceMeshView, viewController: ViewController? = nil) {
            self.faceMeshView = faceMeshView
            self.viewController = viewController
        }
        
        func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
            let faceMesh = ARSCNFaceGeometry(device: (viewController?.sceneView.device)!)
            let node = SCNNode(geometry: faceMesh)
            node.geometry?.firstMaterial?.fillMode = .lines
//            node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: self.getImage(35))
            return node
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            if let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry {
                faceGeometry.update(from: faceAnchor.geometry)
//                expression(anchor: faceAnchor)
                
                DispatchQueue.main.async {
                    // Disable UIKit label in Main.storyboard
                    // self.faceLabel.text = self.analysis
                    // Report changes to SwiftUI code
                    
                    if self.stepRerender == 1 {
                        node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: self.getImage(self.index))
                        print("updateeee")
                        if self.index < 71 {
                            self.index += 1
                        } else {
                            self.index = 1
                        }
                        self.stepRerender = 0
                    } else {
                        self.stepRerender += 1
                    }
                    
//                    self.reportChange()
                }
                
            }
        }
        
//        func expression(anchor: ARFaceAnchor) {
//            let smileLeft = anchor.blendShapes[.mouthSmileLeft]
//            let smileRight = anchor.blendShapes[.mouthSmileRight]
//            let cheekPuff = anchor.blendShapes[.cheekPuff]
//            let tongue = anchor.blendShapes[.tongueOut]
//            self.analysis = ""
//            
//            if ((smileLeft?.decimalValue ?? 0.0) + (smileRight?.decimalValue ?? 0.0)) > 0.9 {
//                self.analysis += "You are smiling. "
//            }
//            
//            if cheekPuff?.decimalValue ?? 0.0 > 0.1 {
//                self.analysis += "Your cheeks are puffed. "
//            }
//            
//            if tongue?.decimalValue ?? 0.0 > 0.1 {
//                self.analysis += "Don't stick your tongue out! "
//            }
//        }
        
        private func getImage(_ index: Int) -> String {
            return "\(index)"
        }
        
        func recorder(didEndRecording path: URL, with noError: Bool) {
            print("didEndRecording")
        }
        
        func recorder(didFailRecording error: Error?, and status: String) {
            print("didFailRecording")
        }
        
        func recorder(willEnterBackground status: ARVideoKit.RecordARStatus) {
            print("willEnterBackground")
        }
        
        private func captureAndDetectFaceWithVision() {
            guard let captureImage = faceMeshView.recordViewModel.recordAR?.photo() else { return }
            
        }
    }
}

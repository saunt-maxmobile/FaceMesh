//
//  ViewController.swift
//  True Depth
//
//  Created by Sai Kambampati on 2/23/19.
//  Copyright © 2019 AppCoda. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SwiftUI
import ARVideoKit

class ViewController: UIViewController, ARSCNViewDelegate {

    var sceneView: ARSCNView = ARSCNView()
    var analysis = ""
    var reportChange: (() -> Void)!
    
    var stepRerender: Int = 0
    var index: Int = 0
    
    var recordViewModel: RecordViewModel
    
    init(recordViewModel: RecordViewModel) {
        self.recordViewModel = recordViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        print("ViewController viewDidLoad")
        super.viewDidLoad()
        
        sceneView.frame = view.bounds
        
        sceneView.delegate = self
        sceneView.showsStatistics = true
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking is not supported on this device")
            return
        }
        
//        let recordAR = RecordAR(ARSceneKit: self.sceneView)
//        recordAR?.contentMode = .aspectFill
//        recordAR?.fps = .fps60
//        recordAR?.videoOrientation = .auto
//        
//        recordAR?.record()
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute:  {
//            recordAR?.stopAndExport({ videoPath, permissionStatus, exported in
//                print("videoPath: \(videoPath)")
//                print("permissionStatus: \(permissionStatus)")
//                print("exported: \(exported)")
//            })
//        })
        
        recordViewModel.recordAR = RecordAR(ARSceneKit: self.sceneView)
        recordViewModel.recordAR!.contentMode = .aspectFill
//        recordViewModel.recordAR!.fps = .fps60
//        recordViewModel.recordAR!.videoOrientation = .auto
        
//        recordViewModel.recordAR!.record()
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute:  {
//            self.recordViewModel.recordAR!.stopAndExport({ videoPath, permissionStatus, exported in
//                print("videoPath: \(videoPath)")
//                print("permissionStatus: \(permissionStatus)")
//                print("exported: \(exported)")
//            })
//        })
        
        view.addSubview(sceneView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("ViewController viewWillAppear")

        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARFaceTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("ViewController viewWillDisappear")

        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let faceMesh = ARSCNFaceGeometry(device: sceneView.device!)
        let node = SCNNode(geometry: faceMesh)
        node.geometry?.firstMaterial?.fillMode = .lines
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry {
            faceGeometry.update(from: faceAnchor.geometry)
            expression(anchor: faceAnchor)
            
            DispatchQueue.main.async {
                // Disable UIKit label in Main.storyboard
                // self.faceLabel.text = self.analysis
                // Report changes to SwiftUI code
                
                if self.stepRerender == 4 {
                    node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: self.getImage(self.index))
                    self.reportChange()
                    if self.index < 5 {
                        self.index += 1
                    } else {
                        self.index = 0
                    }
                    self.stepRerender = 0
                } else {
                    self.stepRerender += 1
                }
                
                self.reportChange()
            }
            
        }
    }
    
    func expression(anchor: ARFaceAnchor) {
        let smileLeft = anchor.blendShapes[.mouthSmileLeft]
        let smileRight = anchor.blendShapes[.mouthSmileRight]
        let cheekPuff = anchor.blendShapes[.cheekPuff]
        let tongue = anchor.blendShapes[.tongueOut]
        self.analysis = ""
        
        if ((smileLeft?.decimalValue ?? 0.0) + (smileRight?.decimalValue ?? 0.0)) > 0.9 {
            self.analysis += "You are smiling. "
        }
        
        if cheekPuff?.decimalValue ?? 0.0 > 0.1 {
            self.analysis += "Your cheeks are puffed. "
        }
        
        if tongue?.decimalValue ?? 0.0 > 0.1 {
            self.analysis += "Don't stick your tongue out! "
        }
    }
    
    private func getImage(_ index: Int) -> String {
        return "image.\(index)"
    }
}

extension ViewController: RecordARDelegate {
    func recorder(didEndRecording path: URL, with noError: Bool) {
        print("did end recording")
    }
    
    func recorder(didFailRecording error: Error?, and status: String) {
        print("didFailRecording")
    
    }
    
    func recorder(willEnterBackground status: ARVideoKit.RecordARStatus) {
            print("willEnterBackground")
    }
    
    
}

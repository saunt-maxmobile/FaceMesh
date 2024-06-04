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
            sceneView.session.delegate = coordinator
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
    class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate, RecordARDelegate {
        var faceMeshView: FaceMeshView
        var viewController: ViewController?
        
        var stepRerender: Int = 0
        var index: Int = 0
        
        init(faceMeshView: FaceMeshView, viewController: ViewController? = nil) {
            self.faceMeshView = faceMeshView
            self.viewController = viewController
        }
        
        func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {

            guard let faceAnchor = anchor as? ARFaceAnchor else { return nil }
            let faceMesh = ARSCNFaceGeometry(device: (viewController?.sceneView.device)!)!
            let node = SCNNode(geometry: faceMesh)
            node.geometry?.firstMaterial?.fillMode = .lines
            updateFaceGeometry(faceMesh, with: faceAnchor.geometry)
            
            autoreleasepool {
                for n in nodePosition {
                    node.addChildNode(Node(vertexNumber: "\(n)"))
                }
            }
            
            let line: SCNNode = line(startPoint: SCNVector3Make(0, 0, 0), endPoint: SCNVector3Make(0, 0, 0), color: .white)
            line.name = "Line"
            node.addChildNode(line)
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
//                for n in nodePosition {
//                    let newNode = Node(vertexNumber: "\(n)")
//                    node.addChildNode(Node(vertexNumber: "\(n)"))
//                }
//            })
            
            return node
        }
        
        func updateFaceGeometry(_ faceGeometry: ARSCNFaceGeometry, with faceMesh: ARFaceGeometry) {
            faceGeometry.update(from: faceMesh)
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            if let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry {
                faceGeometry.update(from: faceAnchor.geometry)
                
//                update image render
                DispatchQueue.main.async {
                    if self.stepRerender == 0 {
                        node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: self.getImage(self.index))
                        node.geometry?.firstMaterial?.transparency = 0.5
                        if self.index < 71 {
                            self.index += 1
                        } else {
                            self.index = 1
                        }
                        self.stepRerender = 0
                    } else {
                        self.stepRerender += 1
                    }
                }
                
                update(for: node, using: faceAnchor)
                
//                node.childNodes.forEach { $0.removeFromParentNode() }
//                
//                let eyeLeftTransform = faceAnchor.leftEyeTransform
//                let eyeRightTransform = faceAnchor.rightEyeTransform
//                
//                let mouthRight = faceAnchor.blendShapes[.mouthRight]
//                let mouthLeft = faceAnchor.blendShapes[.mouthRight]
                
//                print("x: \(eyeLeftTransform.columns.3.x)")
//                print("y: \(eyeLeftTransform.columns.3.y)")
//                print("x: \(eyeLeftTransform.columns.3.z)")
                
//                let browDownLeft = faceAnchor.blendShapes[.browDownLeft]
//                print(browDownLeft)
//
//                let noseTransform = faceAnchor.transform(for: .nose)
//                let mouthTransform = faceAnchor.transform(for: .mouth)
//                
//                let eyeLeftPosition = SCNVector3(eyeLeftTransform.columns.3.x, eyeLeftTransform.columns.3.y, eyeLeftTransform.columns.3.z)
//                let eyeRightPosition = SCNVector3(eyeRightTransform.columns.3.x, eyeRightTransform.columns.3.y, eyeRightTransform.columns.3.z)
//                let nosePosition = SCNVector3(noseTransform.columns.3.x, noseTransform.columns.3.y, noseTransform.columns.3.z)
//                let mouthPosition = SCNVector3(mouthTransform.columns.3.x, mouthTransform.columns.3.y, mouthTransform.columns.3.z)
//                
//                print("eyeLeftPosition: \(eyeLeftPosition)")
//                print("eyeRightPosition: \(eyeRightPosition)")
//                print("nosePosition: \(nosePosition)")
//                print("mouthPosition: \(mouthPosition)")
                
//                node.childNodes.forEach { $0.removeFromParentNode() }
//                
//                // Vẽ các đường thẳng vuông góc
//                let eyeLeftNode = SCNNode(geometry: SCNSphere(radius: 0.005))
//                eyeLeftNode.position = eyeLeftPosition
//                let eyeRightNode = SCNNode(geometry: SCNSphere(radius: 0.005))
//                eyeRightNode.position = eyeRightPosition
//                let noseNode = SCNNode(geometry: SCNSphere(radius: 0.005))
//                noseNode.position = nosePosition
//                let mouthNode = SCNNode(geometry: SCNSphere(radius: 0.005))
//                mouthNode.position = mouthPosition
//                
//                let lineNode1 = lineNode(from: eyeLeftPosition, to: nosePosition)
//                let lineNode2 = lineNode(from: eyeRightPosition, to: nosePosition)
//                let lineNode3 = lineNode(from: nosePosition, to: mouthPosition)
                
//                node.addChildNode(eyeLeftNode)
//                node.addChildNode(eyeRightNode)
//                node.addChildNode(noseNode)
//                node.addChildNode(mouthNode)
//                node.addChildNode(lineNode1)
//                node.addChildNode(lineNode2)
//                node.addChildNode(lineNode3)
            }
        }
        
        func lineNode(from: SCNVector3, to: SCNVector3) -> SCNNode {
                let vector = to - from
                let distance = vector.length()
                let cylinder = SCNCylinder(radius: 0.001, height: CGFloat(distance))
                cylinder.radialSegmentCount = 5
                cylinder.firstMaterial?.diffuse.contents = UIColor.red
                
                let lineNode = SCNNode(geometry: cylinder)
//                lineNode.position = (to + from) / 2
                lineNode.position = SCNVector3((to.x + from.x) / 2, (to.y + from.y) / 2, (to.z + from.z) / 2)
                lineNode.eulerAngles = SCNVector3.lineEulerAngles(vector: vector)
                
                return lineNode
            }
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            for anchor in anchors {
                if let faceAnchor = anchor as? ARFaceAnchor {
                    // Get specific point (for example, the tip of the nose)
//                    let noseTipIndex = faceAnchor.geometry.vertexCount / 2 // Example index, you might need to adjust this
//                    let noseTipPosition = faceAnchor.geometry.vertices[noseTipIndex]
//                    print("Nose tip position: \(noseTipPosition)")
//                    print("\(faceAnchor.geometry.textureCoordinates)")
//                    print("\(faceAnchor.geometry.triangleCount)")
//                    print("\(faceAnchor.geometry.triangleIndices)")
//                    print("\(faceAnchor.geometry.vertices)")
                }
            }
        }
        
        
        func update(for node: SCNNode, using anchor: ARFaceAnchor) {
            for n in 0...anchor.geometry.vertices.count - 1 {
//            for n in nodePosition {
                let child = node.childNode(withName: "\(n)", recursively: false) as? Node
                
                guard let number = child?.name, let vertex = Int(number) else { return }
                let vertices: [vector_float3] = [anchor.geometry.vertices[vertex]]
                
                child?.updatePosition(for: vertices)
            }
            
            drawLine(name: "Line", startPointName: "1102", endPointName: "358", node: node, using: anchor)
        }
        
        private func line(startPoint: SCNVector3, endPoint: SCNVector3, color : UIColor) -> SCNNode {
            let vertices: [SCNVector3] = [startPoint, endPoint]
            let data = NSData(bytes: vertices, length: MemoryLayout<SCNVector3>.size * vertices.count) as Data
            
            let vertexSource = SCNGeometrySource(data: data,
                                                 semantic: .vertex,
                                                 vectorCount: vertices.count,
                                                 usesFloatComponents: true,
                                                 componentsPerVector: 3,
                                                 bytesPerComponent: MemoryLayout<Float>.size,
                                                 dataOffset: 0,
                                                 dataStride: MemoryLayout<SCNVector3>.stride)
            
            
            let indices: [Int32] = [ 0, 1]
            
            let indexData = NSData(bytes: indices, length: MemoryLayout<Int32>.size * indices.count) as Data
            
            let element = SCNGeometryElement(data: indexData,
                                             primitiveType: .line,
                                             primitiveCount: indices.count/2,
                                             bytesPerIndex: MemoryLayout<Int32>.size)
            
            let line = SCNGeometry(sources: [vertexSource], elements: [element])
            
            line.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant
            line.firstMaterial?.diffuse.contents = color
            
            let lineNode = SCNNode(geometry: line)
            return lineNode;
        }
        
        private func line(startPoint: SCNVector3, endPoint: SCNVector3, color : UIColor) -> SCNGeometry {
            let vertices: [SCNVector3] = [startPoint, endPoint]
            let data = NSData(bytes: vertices, length: MemoryLayout<SCNVector3>.size * vertices.count) as Data
            
            let vertexSource = SCNGeometrySource(data: data,
                                                 semantic: .vertex,
                                                 vectorCount: vertices.count,
                                                 usesFloatComponents: true,
                                                 componentsPerVector: 3,
                                                 bytesPerComponent: MemoryLayout<Float>.size,
                                                 dataOffset: 0,
                                                 dataStride: MemoryLayout<SCNVector3>.stride)
            
            
            let indices: [Int32] = [ 0, 1]
            
            let indexData = NSData(bytes: indices, length: MemoryLayout<Int32>.size * indices.count) as Data
            
            let element = SCNGeometryElement(data: indexData,
                                             primitiveType: .line,
                                             primitiveCount: indices.count/2,
                                             bytesPerIndex: MemoryLayout<Int32>.size)
            
            let line = SCNGeometry(sources: [vertexSource], elements: [element])
            
            return line;
        }
        
        private func drawLine(name: String, startPointName: String, endPointName: String, node: SCNNode, using anchor: ARFaceAnchor, color: UIColor = .white) {
            guard let startPointNode = node.childNode(withName: startPointName, recursively: false) as? Node else { return }
            guard let startPointNumber = startPointNode.name, let vertexStartPoint = Int(startPointNumber) else { return }
            let startPointPosition = anchor.geometry.vertices[vertexStartPoint]
            
            guard let endPointNode = node.childNode(withName: endPointName, recursively: false) as? Node else { return }
            guard let endPointNumber = endPointNode.name, let vertexEndPoint = Int(endPointNumber) else { return }
            let endPointPosition = anchor.geometry.vertices[vertexEndPoint]
            
            guard let line = node.childNode(withName: name, recursively: false) else { return }
            line.removeFromParentNode()
            let lineGeometry: SCNGeometry = self.line(startPoint: SCNVector3Make(startPointPosition.x, startPointPosition.y, startPointPosition.z), endPoint: SCNVector3Make(endPointPosition.x, endPointPosition.y, endPointPosition.z), color: .white)
            line.geometry = lineGeometry
            node.addChildNode(line)
            getDistance(from: startPointNode, to: endPointNode, node: node, using: anchor)
        }
        
        private func getDistance(from startPoint: Node, to endPoint: Node, node: SCNNode, using anchor: ARFaceAnchor) -> Float {
            let distance = startPoint.position.distance(to: endPoint.position)
            print("distance : \(distance)")
            return distance
        }
        
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

extension simd_float4x4 {
    init(translation: SIMD3<Float>) {
        self = matrix_identity_float4x4
        columns.3 = SIMD4<Float>(translation.x, translation.y, translation.z, 1.0)
    }
}

extension SCNVector3 {
    static func lineEulerAngles(vector: SCNVector3) -> SCNVector3 {
        let x = vector.x
        let y = vector.y
        let z = vector.z
        let xyDistance = sqrt(x*x + y*y)
        let xzDistance = sqrt(x*x + z*z)
        let xAngle = atan2(y, xyDistance)
        let yAngle = atan2(xzDistance, z)
        return SCNVector3(xAngle, yAngle, 0)
    }
}

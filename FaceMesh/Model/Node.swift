//
//  Node.swift
//  FaceMesh
//
//  Created by MaxMobile Software on 31/5/24.
//  Copyright © 2024 AppCoda. All rights reserved.
//

import Foundation
import SceneKit


final class Node: SCNNode {
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    init(vertexNumber: String) {
        super.init()
        
        name = vertexNumber
        
        let text = SCNText(string: vertexNumber, extrusionDepth: 0.0)
        text.firstMaterial?.diffuse.contents = UIColor.yellow
        scale = SCNVector3(0.0001, 0.0001, 0.0001) // Adjust this to make the numbers on the face larger
        
        geometry = text
    }
    
//    func updatePosition(for vectors: [vector_float3]) {
//        let newPos = vectors.reduce(vector_float3(), +) / Float(vectors.count)
//        position = SCNVector3(newPos)
//    }
    
}

extension SCNNode {
    func updatePosition(for vectors: [vector_float3]) {
        let newPos = vectors.reduce(vector_float3(), +) / Float(vectors.count)
        position = SCNVector3(newPos)
    }
}

extension SCNVector3 {
     func distance(to vector: SCNVector3) -> Float {
         return simd_distance(simd_float3(self), simd_float3(vector))
     }
    
    static func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
    }
    
    static func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x - right.x, left.y - right.y, left.z - right.z)
    }
    
    func length() -> Float {
        return sqrt(x*x + y*y + z*z)
    }
 }

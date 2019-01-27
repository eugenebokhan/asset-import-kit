//
//  aiNode + makeTangentGeometrySource.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 02/12/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import SceneKit
import assimp.scene

extension aiNode {
    
    @available(OSX 10.12, iOS 10.0, *)
    /// Creates a scenekit geometry source from the tangents of the specified node.
    ///
    /// - Parameter aiScene: The assimp scene.
    /// - Returns: The assimp scene.
    func makeTangentGeometrySource(from aiScene: aiScene) -> SCNGeometrySource {
        let numberOfVertices = getNumberOfVertices(in: aiScene)
        let scnTangents = UnsafeMutablePointer<Float32>.allocate(capacity: numberOfVertices * 3)
        defer { scnTangents.deallocate() }
        var verticesCounter: Int = 0
        let aiMeshes = getMeshes(from: aiScene)
        for aiMesh in aiMeshes {
            if let aiMeshTangents = aiMesh.mTangents {
                print("Getting tangents")
                for vertexIndex in 0 ..< Int(aiMesh.mNumVertices) {
                    let aiVector3D = aiMeshTangents[vertexIndex]
                    scnTangents[verticesCounter] = aiVector3D.x
                    verticesCounter += 1
                    scnTangents[verticesCounter] = aiVector3D.y
                    verticesCounter += 1
                    scnTangents[verticesCounter] = aiVector3D.z
                    verticesCounter += 1
                }
            }
        }
        
        let dataLength = numberOfVertices * 3 * MemoryLayout<Float32>.size
        let data = NSData(bytes: scnTangents, length: dataLength) as Data
        let bytesPerComponent = MemoryLayout<Float32>.size
        let dataStride = 3 * bytesPerComponent
        let tangentSource = SCNGeometrySource(data: data,
                                              semantic: .tangent,
                                              vectorCount: numberOfVertices,
                                              usesFloatComponents: true,
                                              componentsPerVector: 3,
                                              bytesPerComponent: bytesPerComponent,
                                              dataOffset: 0,
                                              dataStride: dataStride)
        return tangentSource
    }
    
    
}

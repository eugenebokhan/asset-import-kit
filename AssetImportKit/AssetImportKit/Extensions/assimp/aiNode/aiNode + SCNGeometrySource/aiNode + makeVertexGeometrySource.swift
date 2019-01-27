//
//  aiNode + makeVertexGeometrySource.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 02/12/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import SceneKit
import assimp.scene

extension aiNode {
    
    /// Creates a scenekit geometry source from the vertices of the specified node.
    ///
    /// - Parameter aiScene: The assimp scene.
    /// - Returns: A new geometry source whose semantic property is vertex.
    func makeVertexGeometrySource(from aiScene: aiScene) -> SCNGeometrySource {
        let numberOfVertices = getNumberOfVertices(in: aiScene)
        let scnVertices = UnsafeMutablePointer<Float32>.allocate(capacity: numberOfVertices * 3)
        defer { scnVertices.deallocate() }
        var verticesCounter: Int = 0
        let aiMeshes = getMeshes(from: aiScene)
        for aiMesh in aiMeshes {
            if let aiMeshVertices = aiMesh.mVertices {
                print("Getting vertices")
                for vertexIndex in 0 ..< Int(aiMesh.mNumVertices) {
                    let aiVector3D = aiMeshVertices[vertexIndex]
                    scnVertices[verticesCounter] = aiVector3D.x
                    verticesCounter += 1
                    scnVertices[verticesCounter] = aiVector3D.y
                    verticesCounter += 1
                    scnVertices[verticesCounter] = aiVector3D.z
                    verticesCounter += 1
                }
            }
        }

        let dataLength = numberOfVertices * 3 * MemoryLayout<Float32>.size
        let data = NSData(bytes: scnVertices, length: dataLength) as Data
        let bytesPerComponent = MemoryLayout<Float32>.size
        let dataStride = 3 * bytesPerComponent
        let vertexSource = SCNGeometrySource(data: data,
                                             semantic: .vertex,
                                             vectorCount: numberOfVertices,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: bytesPerComponent,
                                             dataOffset: 0,
                                             dataStride: dataStride)
        return vertexSource
    }
    
}

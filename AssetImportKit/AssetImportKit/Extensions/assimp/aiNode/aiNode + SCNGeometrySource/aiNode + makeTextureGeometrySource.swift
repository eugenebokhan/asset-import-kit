//
//  aiNode + makeTextureGeometrySource.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 02/12/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import SceneKit
import assimp.scene

extension aiNode {

    /// Creates a scenekit geometry source from the texture coordinates of the
    /// makeTextureGeometrySourceForNodespecified node.
    ///
    /// - Parameter aiScene: The assimp scene.
    /// - Returns: A new geometry source whose semantic property is texcoord.
    func makeTextureGeometrySource(from aiScene: aiScene) -> SCNGeometrySource {
        let numberOfVertices = getNumberOfVertices(in: aiScene)
        let scnTextures = UnsafeMutablePointer<Float32>.allocate(capacity: numberOfVertices * 3)
        defer { scnTextures.deallocate() }
        var verticesCounter: Int = 0
        let aiMeshes = getMeshes(from: aiScene)
        for aiMesh in aiMeshes {
            if let textureCoordinates = aiMesh.mTextureCoords.0 {
                print("Getting texture coordinates")
                for vertexIndex in 0 ..< Int(aiMesh.mNumVertices) {
                    let x = textureCoordinates[vertexIndex].x
                    let y = textureCoordinates[vertexIndex].y
                    scnTextures[verticesCounter] = x
                    verticesCounter += 1
                    scnTextures[verticesCounter] = y
                    verticesCounter += 1
                }
            }
        }
        
        let dataLength = numberOfVertices * 2 * MemoryLayout<Float32>.size
        let data = NSData(bytes: scnTextures, length: dataLength) as Data
        let bytesPerComponent = MemoryLayout<Float32>.size
        let dataStride = 2 * bytesPerComponent
        let textureSource = SCNGeometrySource(data: data,
                                              semantic: .texcoord,
                                              vectorCount: numberOfVertices,
                                              usesFloatComponents: true,
                                              componentsPerVector: 2,
                                              bytesPerComponent: bytesPerComponent,
                                              dataOffset: 0,
                                              dataStride: dataStride)
        return textureSource
    }
    
}

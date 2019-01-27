//
//  aiNode + makeColorGeometrySource.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 02/12/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import SceneKit
import assimp.scene

extension aiNode {
    
    /// Creates a scenekit vertex color source from the vertex color information of
    /// the specified node.
    ///
    /// - Parameter aiScene: The assimp scene.
    /// - Returns: A new color source whose semantic property is vertex color.
    func makeColorGeometrySource(from aiScene: aiScene) -> SCNGeometrySource? {
        let numberOfVertices = getNumberOfVertices(in: aiScene)
        let scnColors = UnsafeMutablePointer<Float32>.allocate(capacity: numberOfVertices * 3)
        defer { scnColors.deallocate() }
        var colorsCounter: Int = 0
        let aiMeshes = getMeshes(from: aiScene)
        for aiMesh in aiMeshes {
            if let aiColors = aiMesh.mColors.0 {
                print("Getting colors")
                for vertexIndex in 0 ..< Int(aiMesh.mNumVertices) {
                    scnColors[colorsCounter] = aiColors[vertexIndex].r
                    colorsCounter += 1
                    scnColors[colorsCounter] = aiColors[vertexIndex].g
                    colorsCounter += 1
                    scnColors[colorsCounter] = aiColors[vertexIndex].b
                    colorsCounter += 1
                }
            } else {
                return nil
            }
        }
        
        let dataLength = numberOfVertices * 3 * MemoryLayout<Float32>.size
        let nsData = NSData(bytes: scnColors, length: dataLength)
        let data = nsData as Data
        let bytesPerComponent = MemoryLayout<Float32>.size
        let dataStride = 3 * bytesPerComponent
        let colorSource = SCNGeometrySource(data: data,
                                            semantic: .color,
                                            vectorCount: numberOfVertices,
                                            usesFloatComponents: true,
                                            componentsPerVector: 3,
                                            bytesPerComponent: bytesPerComponent,
                                            dataOffset: 0,
                                            dataStride: dataStride)
        return colorSource
    }
    
}

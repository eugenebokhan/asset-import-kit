//
//  aiNode + makeGeometryElementsForNode.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 02/12/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import SceneKit
import assimp.scene

extension aiNode {
    
    /// Creates an array of scenekit geometry element obejcts describing how to
    /// connect the geometry's vertices of the specified node.
    ///
    /// - Parameter aiScene: The assimp node.
    /// - Returns: An array of geometry elements.
    func makeGeometryElementsForNode(from aiScene: aiScene) -> [SCNGeometryElement] {
        
        var scnGeometryElements: [SCNGeometryElement] = []
        var indexOffset: Int = 0
        let aiMeshes = getMeshes(from: aiScene)
        for aiMesh in aiMeshes {
            let numberOfFaces = Int(aiMesh.mNumFaces)
            if let indices = aiMesh.makeIndicesGeometryElement(with: indexOffset,
                                                               numberOfFaces: numberOfFaces) {
                scnGeometryElements.append(indices)
            }
            indexOffset += Int(aiMesh.mNumVertices)
        }
        return scnGeometryElements
    }
    
}

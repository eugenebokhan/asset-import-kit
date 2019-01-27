//
//  aiNode + getNumberOfVertices.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 01/12/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import assimp.scene

extension aiNode {
    
    /// Find the number of vertices, faces and indices of a geometry.
    ///
    /// Finds the total number of vertices in the meshes of the specified node.
    ///
    /// - Parameters:
    ///     -aiScene: The assimp scene.
    /// - Returns:
    ///     The number of vertices.
    func getNumberOfVertices(in aiScene: aiScene) -> Int {
        var nVertices: Int = 0
        let aiNodeMeshes = getMeshes(from: aiScene)
        for aiMesh in aiNodeMeshes {
            let numberOfVertices = Int(aiMesh.mNumVertices)
            nVertices += numberOfVertices
        }
        return nVertices
    }
    
}

//
//  aiNode + getNumberOfBones.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 01/12/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import assimp.scene

extension aiNode {
    
    /// Finds the number of bones in the meshes of the specified node.
    /// - Parameters:
    ///     - aiNode: The assimp node.
    ///     - aiScene: The assimp scene.
    /// - Returns:
    ///     The number of bones.
    func getNumberOfBones(in aiScene: aiScene) -> Int {
        var numberOfBones: Int = 0
        let aiNodeMeshes = getMeshes(from: aiScene)
        for aiMesh in aiNodeMeshes {
            let aiMeshBonesCount = Int(aiMesh.mNumBones)
            numberOfBones += aiMeshBonesCount
        }
        return numberOfBones
    }
    
}

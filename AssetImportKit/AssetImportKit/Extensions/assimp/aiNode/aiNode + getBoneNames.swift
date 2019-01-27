//
//  aiNode + getBoneNames.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 03/12/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import assimp.scene

extension aiNode {
    
    /// Creates an array of bone names in the meshes of the specified node.
    ///
    /// - Parameters:
    ///   - aiNode: The assimp node.
    ///   - aiScene: The assimp scene.
    /// - Returns: An array of bone names.
    func getBoneNames(from aiScene: aiScene) -> [String] {
        var boneNames: [String] = []
        let aiNodeMeshes = getMeshes(from: aiScene)
        for aiMesh in aiNodeMeshes {
            let aiMeshBones = aiMesh.getBones()
            for aiBone in aiMeshBones {
                let name = aiBone.mName.stringValue()
                boneNames.append(name)
            }
        }
        return boneNames
    }
    
}

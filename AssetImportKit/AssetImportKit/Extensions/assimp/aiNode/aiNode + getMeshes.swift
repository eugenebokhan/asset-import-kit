//
//  aiNode + getMeshes.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 29/11/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import assimp.scene

extension aiNode {
    
    func getMeshes(from aiScene: aiScene) -> [aiMesh] {
        let sceneMeshes = aiScene.getMeshes()
        let nodeMeshesCount = Int(mNumMeshes)
        var nodeMeshes = Array(repeating: aiMesh(),
                               count: nodeMeshesCount)
        for i in 0 ..< nodeMeshesCount {
            let meshIndex = Int(mMeshes[i])
            let aiMesh = sceneMeshes[meshIndex]
            nodeMeshes[i] = aiMesh
        }
        return nodeMeshes
    }
    
}

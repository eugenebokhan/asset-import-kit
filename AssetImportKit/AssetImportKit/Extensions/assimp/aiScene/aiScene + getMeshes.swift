//
//  aiScene + getMeshes.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 02/12/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import assimp.scene

extension aiScene {
    
    func getMeshes() -> [aiMesh] {
        let meshesCount = Int(mNumMeshes)
        let aiSceneMeshes = Array(UnsafeBufferPointer(start: mMeshes,
                                                      count: meshesCount)).map { $0!.pointee }
        return aiSceneMeshes
    }
    
}

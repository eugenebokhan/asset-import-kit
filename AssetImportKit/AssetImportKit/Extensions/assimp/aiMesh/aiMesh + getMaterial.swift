//
//  aiMesh + getMaterial.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 29/11/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import assimp.scene

extension aiMesh {
    
    func getMaterial(from scene: aiScene) -> aiMaterial {
        let sceneMaterialsCount = Int(scene.mNumMaterials)
        let sceneMaterials = Array(UnsafeBufferPointer(start: scene.mMaterials,
                                                       count: sceneMaterialsCount)).map { $0!.pointee }
        let materialIndex = Int(mMaterialIndex)
        let material = sceneMaterials[materialIndex]
        return material
    }
    
}

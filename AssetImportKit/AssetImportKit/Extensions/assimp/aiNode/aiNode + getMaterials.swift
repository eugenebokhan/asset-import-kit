//
//  aiNode + getMaterials.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 29/11/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import assimp.scene

extension aiNode {
    
    func getMaterials(from scene: aiScene) -> [aiMaterial] {
        return getMeshes(from: scene).map { $0.getMaterial(from: scene) }
    }
    
}

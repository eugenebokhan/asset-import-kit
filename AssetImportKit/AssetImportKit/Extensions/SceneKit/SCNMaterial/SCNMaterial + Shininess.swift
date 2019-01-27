//
//  SCNMaterial + Shininess.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 30/11/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import SceneKit
import assimp.types

extension SCNMaterial {
    
    func loadShininessProperty(from aiMaterial: UnsafePointer<aiMaterial>) {
        print("Loading shininess")
        var shininessRawValue: Int32 = 0
        var max: UInt32 = 0
        aiGetMaterialIntegerArray(aiMaterial,
                                  AI_MATKEY_BLEND_FUNC.pKey,
                                  AI_MATKEY_BLEND_FUNC.type,
                                  AI_MATKEY_BLEND_FUNC.index,
                                  &shininessRawValue,
                                  &max)
        
        print("shininess: \(shininessRawValue)")
        shininess = CGFloat(shininessRawValue)
    }
    
}

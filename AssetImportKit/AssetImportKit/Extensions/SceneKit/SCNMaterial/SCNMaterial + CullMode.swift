//
//  SCNMaterial + CullMode.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 30/11/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import SceneKit
import assimp.types

extension SCNMaterial {
    
    func loadCullModeProperty(from aiMaterial: UnsafePointer<aiMaterial>) {
        print("Loading cull/double sided mode")
        var cullModeRawValue: Int32 = 0
        var max: UInt32 = 0
        aiGetMaterialIntegerArray(aiMaterial,
                                  AI_MATKEY_TWOSIDED.pKey,
                                  AI_MATKEY_TWOSIDED.type,
                                  AI_MATKEY_TWOSIDED.index,
                                  &cullModeRawValue,
                                  &max)
        if cullModeRawValue == 1 {
            cullMode = .front
        } else {
            cullMode = .back
        }
    }
    
}

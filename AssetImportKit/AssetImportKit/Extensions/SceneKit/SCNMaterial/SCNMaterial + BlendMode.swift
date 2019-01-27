//
//  SCNMaterial + BlendMode.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 30/11/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import SceneKit
import assimp.types

extension SCNMaterial {
    
    @available(OSX 10.12, iOS 9.0, *)
    func loadBlendModeProperty(from aiMaterial: UnsafePointer<aiMaterial>) {
        print("Loading blend mode")
        var blendModeRawValue: Int32 = 0
        var max: UInt32 = 0
        aiGetMaterialIntegerArray(aiMaterial,
                                  AI_MATKEY_BLEND_FUNC.pKey,
                                  AI_MATKEY_BLEND_FUNC.type,
                                  AI_MATKEY_BLEND_FUNC.index,
                                  &blendModeRawValue,
                                  &max)
        if blendModeRawValue == Int32(aiBlendMode_Default.rawValue) {
            print("Using alpha blend mode")
            blendMode = .alpha
        }
        else if blendModeRawValue == Int32(aiBlendMode_Additive.rawValue) {
            print("Using add blend mode")
            blendMode = .add
        }
    }
    
}

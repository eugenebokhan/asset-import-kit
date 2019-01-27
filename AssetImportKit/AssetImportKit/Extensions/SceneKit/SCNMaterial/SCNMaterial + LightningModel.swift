//
//  SCNMaterial + LightningModel.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 30/11/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import SceneKit
import assimp.types

extension SCNMaterial {
    
    func loadLightingModelProperty(from aiMaterial: UnsafePointer<aiMaterial>) {
        print("Loading lighting model")
        /**
         FIXME: The shading mode works only on iOS for iPhone.
         Does not work on iOS for iPad and OS X.
         Hence has been defaulted to Blinn.
         USE AI_MATKEY_SHADING_MODEL to get the shading mode.
         */
        var lightingModelRawValue: Int32 = 0
        var max: UInt32 = 0
        aiGetMaterialIntegerArray(aiMaterial,
                                  AI_MATKEY_SHADING_MODEL.pKey,
                                  AI_MATKEY_SHADING_MODEL.type,
                                  AI_MATKEY_SHADING_MODEL.index,
                                  &lightingModelRawValue,
                                  &max)
        
        if lightingModelRawValue == 4 {
            lightingModel = .blinn
        } else if lightingModelRawValue == 3 {
            lightingModel = .phong
        } else {
            if #available(OSX 10.12, iOS 10.0, *) {
                lightingModel = .physicallyBased
            } else {
                lightingModel = .phong
            }
        }
    }
    
}

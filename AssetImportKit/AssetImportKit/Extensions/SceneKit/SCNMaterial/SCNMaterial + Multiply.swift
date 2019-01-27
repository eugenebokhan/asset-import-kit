//
//  SCNMaterial + Multiply.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 30/11/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import SceneKit
import assimp.types

extension SCNMaterial {
    
    /// Updates a scenekit material's multiply property
    ///
    /// - Parameter aiMaterial: The assimp material
    func loadMultiplyProperty(from aiMaterial: UnsafePointer<aiMaterial>) {
        
        print("Loading multiply color")
        
        var color = aiColor4D()
        color.r = 0.0
        color.g = 0.0
        color.b = 0.0
        let  matColor = aiGetMaterialColor(aiMaterial,
                                           AI_MATKEY_COLOR_TRANSPARENT.pKey,
                                           AI_MATKEY_COLOR_TRANSPARENT.type,
                                           AI_MATKEY_COLOR_TRANSPARENT.index,
                                           &color).rawValue
        if aiReturn_SUCCESS.rawValue == matColor {
            
            if color.r != 0 && color.g != 0 && color.b != 0 {
                
                let space = CGColorSpaceCreateDeviceRGB()
                let components: [CGFloat] = [CGFloat(color.r),
                                             CGFloat(color.g),
                                             CGFloat(color.b),
                                             CGFloat(color.a)]
                if let color = CGColor(colorSpace: space,
                                       components: components) {
                    multiply.contents = Color(cgColor: color)
                }
                
            }
            
        }
    }
    
}

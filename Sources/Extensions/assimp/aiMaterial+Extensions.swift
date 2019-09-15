//
//  aiMaterial+Extensions.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 29/11/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import Assimp.material

extension aiMaterial {
    
    var name: String {
        mutating get {
            var nameTempVar = aiString()
            aiGetMaterialString(&self,
                                AI_MATKEY_NAME.pKey,
                                AI_MATKEY_NAME.type,
                                AI_MATKEY_NAME.type,
                                &nameTempVar)
            let materialName = nameTempVar.stringValue()
            return materialName
        }
    }
    
}

//
//  aiBone + getWeights.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 02/12/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import assimp.scene

extension aiBone {
    
    func getVertexWeights() -> [aiVertexWeight] {
        let weightsCount = Int(mNumWeights)
        let vertexWeights = Array(UnsafeBufferPointer(start: mWeights,
                                                      count: weightsCount))
        return vertexWeights
    }
    
}

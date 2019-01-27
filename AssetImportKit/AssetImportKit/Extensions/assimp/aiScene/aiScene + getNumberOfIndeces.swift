//
//  aiScene + getNumberOfIndeces.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 02/12/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import assimp.scene

extension aiScene {
    
    /// Finds the total number of indices in the specified mesh by index.
    ///
    /// - Parameter aiMeshIndex: The assimp mesh index.
    /// - Returns: The total number of indices.
    func getNumberOfFaceIndeces(at aiMeshIndex: Int) -> Int {
        return getMeshes()[aiMeshIndex].getNumberOfFaceIndeces()
    }
    
}


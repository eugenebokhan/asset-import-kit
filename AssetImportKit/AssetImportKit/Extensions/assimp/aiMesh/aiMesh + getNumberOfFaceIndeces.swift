//
//  aiMesh + getNumberOfFaceIndeces.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 02/12/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import assimp.scene

extension aiMesh {
    
    /// Finds the total number of indices in the specified mesh by index.
    ///
    /// - Returns: The total number of indices.
    func getNumberOfFaceIndeces() -> Int {
        var indexCount: Int = 0
        for faceIndex in 0 ..< Int(mNumFaces) {
            let aiFace = mFaces[faceIndex]
            indexCount += Int(aiFace.mNumIndices)
        }
        return indexCount
    }
    
}

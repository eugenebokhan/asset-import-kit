//
//  aiMesh + getBondes.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 02/12/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import assimp.scene

extension aiMesh {
    
    func getBones() -> [aiBone] {
        let bonesCount = Int(mNumBones)
        let aiMeshBones = Array(UnsafeBufferPointer(start: mBones,
                                                       count: bonesCount)).map { $0!.pointee }
        return aiMeshBones
    }
    
}


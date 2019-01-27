//
//  aiScene + getCameras.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 03/12/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import assimp.scene

extension aiScene {
    
    /// Get the cameras of the scene
    ///
    /// - Returns: The cameras of the scene.
    func getCameras() -> [aiCamera] {
        let camerasCount = Int(mNumCameras)
        let aiSceneCameras = Array(UnsafeBufferPointer(start: mCameras,
                                                       count: camerasCount)).map { $0!.pointee }
        return aiSceneCameras
    }
    
}


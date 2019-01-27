//
//  SCNNode + makeSCNCamera.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 03/12/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import SceneKit
import assimp.types

extension SCNNode {
    
    /// Creates a scenekit camera to attach at the specified node.
    ///
    /// - Parameters:
    ///   - aiNode: The assimp node.
    ///   - aiScene: The assimp scene.
    /// - Returns: A new scenekit camera.
    func makeSCNCamera(from aiNode: aiNode,
                       in aiScene: aiScene) -> SCNCamera? {
        let nodeName = aiNode.mName.stringValue()
        let aiSceneCameras = aiScene.getCameras()
        for aiCamera in aiSceneCameras {
            let cameraNodeName = aiCamera.mName.stringValue()
            if (nodeName == cameraNodeName) {
                let camera = SCNCamera()
                if #available(OSX 10.13, iOS 11.0, *) {
                    camera.fieldOfView = CGFloat(aiCamera.mHorizontalFOV)
                }
                camera.zNear = Double(aiCamera.mClipPlaneNear)
                camera.zFar = Double(aiCamera.mClipPlaneFar)
                return camera
            }
        }
        return nil
    }
    
}

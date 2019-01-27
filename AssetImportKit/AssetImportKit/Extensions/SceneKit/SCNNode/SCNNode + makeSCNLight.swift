//
//  SCNNode + makeSCNLight.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 03/12/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import SceneKit
import assimp.types

extension SCNNode {
    
    /// Creates a scenekit light to attach at the specified node.
    ///
    /// - Parameters:
    ///   - aiNode: The assimp node.
    ///   - aiScene: The assimp scene.
    /// - Returns: A new scenekit light.
    func makeSCNLight(from aiNode: aiNode,
                      in aiScene: aiScene) -> SCNLight? {
        
        let aiNodeName = aiNode.mName.stringValue()
        let aiSceneLightsCount = Int(aiScene.mNumLights)
        let aiSceneLights = Array(UnsafeBufferPointer(start: aiScene.mLights,
                                                      count: aiSceneLightsCount)).map { $0!.pointee }
        
        for aiSceneLight in aiSceneLights {
            
            let aiLightNodeName = aiSceneLight.mName.stringValue()
            if aiNodeName == aiLightNodeName {
                print("Creating light for node \(aiNodeName)")
                print("ambient \(aiSceneLight.mColorAmbient.r), \(aiSceneLight.mColorAmbient.g), \(aiSceneLight.mColorAmbient.b) ")
                print("diffuse \(aiSceneLight.mColorAmbient.r), \(aiSceneLight.mColorAmbient.g), \(aiSceneLight.mColorAmbient.b) ")
                print("specular \(aiSceneLight.mColorAmbient.r), \(aiSceneLight.mColorAmbient.g), \(aiSceneLight.mColorAmbient.b) ")
                print("inner angle \(aiSceneLight.mAngleInnerCone)")
                print("outer angle \(aiSceneLight.mAngleOuterCone)")
                print("att const \(aiSceneLight.mAttenuationConstant)")
                print("att linear \(aiSceneLight.mAttenuationLinear)")
                print("att quad \(aiSceneLight.mAttenuationQuadratic)")
                print("position \(aiSceneLight.mColorAmbient.r), \(aiSceneLight.mColorAmbient.g), \(aiSceneLight.mColorAmbient.b) ")
                
                return SCNLight(from: aiSceneLight)
            }
        }
        return nil
    }
    
}



//
//  SCNLight + aiLight.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 30/11/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import SceneKit
import assimp.types

extension SCNLight {
    
    convenience init(from aiLight: aiLight) {
        self.init()
        switch aiLight.mType {
        case aiLightSource_DIRECTIONAL,
             aiLightSource_AREA,
             aiLightSource_UNDEFINED:
            applyDirectinalLightProperties(from: aiLight)
        case aiLightSource_POINT:
            applySpotLightProperties(from: aiLight)
        case aiLightSource_SPOT:
            applyOmniLightProperties(from: aiLight)
        case aiLightSource_AMBIENT:
            applyAmbientLightProperties(from: aiLight)
        default:
            break
        }
    }
    
    /// Creates a scenekit directional light from an assimp directional light.
    ///
    /// - Parameter aiLight: The assimp directional light.
    private func applyDirectinalLightProperties(from aiLight: aiLight) {
        type = .directional
        let aiColor = aiLight.mColorSpecular
        if aiColor.r != 0
            && aiColor.g != 0
            && aiColor.b != 0 {
            print("Setting color: \(aiColor.r) \(aiColor.g) \(aiColor.b) ")
            let space = CGColorSpaceCreateDeviceRGB()
            let components: [CGFloat] = [CGFloat(aiColor.r),
                                         CGFloat(aiColor.g),
                                         CGFloat(aiColor.b),
                                         1.0]
            if let cgColor = CGColor(colorSpace: space,
                                     components: components) {
                color = cgColor
            }
        }
    }
    
    /// Creates a scenekit omni light from an assimp omni light.
    ///
    /// - Parameter aiLight: The assimp omni light.
    private func applyOmniLightProperties(from aiLight: aiLight) {
        type = .omni
        let aiColor = aiLight.mColorSpecular
        if aiColor.r != 0
            && aiColor.g != 0
            && aiColor.b != 0 {
            print("Setting color: \(aiColor.r) \(aiColor.g) \(aiColor.b) ")
            let space = CGColorSpaceCreateDeviceRGB()
            let components: [CGFloat] = [CGFloat(aiColor.r),
                                         CGFloat(aiColor.g),
                                         CGFloat(aiColor.b),
                                         1.0]
            if let cgColor = CGColor(colorSpace: space,
                                     components: components) {
                color = cgColor
            }
        }
        if aiLight.mAttenuationQuadratic != 0 {
            attenuationFalloffExponent = 2
        } else if aiLight.mAttenuationLinear != 0 {
            attenuationFalloffExponent = 1
        }
    }
    
    /// Creates a scenekit spot light from an assimp spot light.
    ///
    /// - Parameter aiLight: The assimp spot light.
    private func applySpotLightProperties(from aiLight: aiLight) {
        type = .spot
        let aiColor = aiLight.mColorSpecular
        if aiColor.r != 0
            && aiColor.g != 0
            && aiColor.b != 0 {
            print("Setting color: \(aiColor.r) \(aiColor.g) \(aiColor.b) ")
            let space = CGColorSpaceCreateDeviceRGB()
            let components: [CGFloat] = [CGFloat(aiColor.r),
                                         CGFloat(aiColor.g),
                                         CGFloat(aiColor.b),
                                         1.0]
            if let cgColor = CGColor(colorSpace: space,
                                     components: components) {
                color = cgColor
            }
        }
        if aiLight.mAttenuationQuadratic != 0 {
            attenuationFalloffExponent = 2.0
        }
        else if aiLight.mAttenuationLinear != 0 {
            attenuationFalloffExponent = 1.0
        }
        attenuationStartDistance = 0
        attenuationEndDistance = 0
        spotInnerAngle = CGFloat(aiLight.mAngleInnerCone)
        spotOuterAngle = CGFloat(aiLight.mAngleOuterCone)
    }
    
    
    /// Creates a scenekit ambient light from an assimp spot light.
    ///
    /// - Parameter aiLight: The assimp spot light.
    private func applyAmbientLightProperties(from aiLight: aiLight) {
        type = .ambient
        let aiColor = aiLight.mColorAmbient
        if aiColor.r != 0
            && aiColor.g != 0
            && aiColor.b != 0 {
            print("Setting color: \(aiColor.r) \(aiColor.g) \(aiColor.b) ")
            let space = CGColorSpaceCreateDeviceRGB()
            let components: [CGFloat] = [CGFloat(aiColor.r),
                                         CGFloat(aiColor.g),
                                         CGFloat(aiColor.b),
                                         1.0]
            if let cgColor = CGColor(colorSpace: space,
                                     components: components) {
                color = cgColor
            }
        }
    }
}

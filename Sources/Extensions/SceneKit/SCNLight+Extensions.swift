//
//  SCNLight+Extensions.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 30/11/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import SceneKit
import Assimp

extension SCNLight {
    
    convenience init(from aiLight: aiLight) {
        self.init()
        switch aiLight.mType {
        case aiLightSource_DIRECTIONAL,
             aiLightSource_AREA,
             aiLightSource_UNDEFINED:
            self.applyDirectinalLightProperties(from: aiLight)
        case aiLightSource_POINT:
            self.applySpotLightProperties(from: aiLight)
        case aiLightSource_SPOT:
            self.applyOmniLightProperties(from: aiLight)
        case aiLightSource_AMBIENT:
            self.applyAmbientLightProperties(from: aiLight)
        default:
            break
        }
    }
    
    /// Creates a scenekit directional light from an assimp directional light.
    ///
    /// - Parameter aiLight: The assimp directional light.
    private func applyDirectinalLightProperties(from aiLight: aiLight) {
        self.type = .directional
        let aiColor = aiLight.mColorSpecular
        debugPrint("Setting color: \(aiColor.r) \(aiColor.g) \(aiColor.b)")
        let space = CGColorSpaceCreateDeviceRGB()
        let components: [CGFloat] = [CGFloat(aiColor.r),
                                     CGFloat(aiColor.g),
                                     CGFloat(aiColor.b),
                                     1.0]
        if let cgColor = CGColor(colorSpace: space,
                                 components: components) {
            self.color = cgColor
        }
    }
    
    /// Creates a scenekit omni light from an assimp omni light.
    ///
    /// - Parameter aiLight: The assimp omni light.
    private func applyOmniLightProperties(from aiLight: aiLight) {
        self.type = .omni
        let aiColor = aiLight.mColorSpecular
        debugPrint("Setting color: \(aiColor.r) \(aiColor.g) \(aiColor.b)")
        let space = CGColorSpaceCreateDeviceRGB()
        let components: [CGFloat] = [CGFloat(aiColor.r),
                                     CGFloat(aiColor.g),
                                     CGFloat(aiColor.b),
                                     1.0]
        if let cgColor = CGColor(colorSpace: space,
                                 components: components) {
            self.color = cgColor
        }
        if aiLight.mAttenuationQuadratic != 0 {
            self.attenuationFalloffExponent = 2
        } else if aiLight.mAttenuationLinear != 0 {
            self.attenuationFalloffExponent = 1
        }
    }
    
    /// Creates a scenekit spot light from an assimp spot light.
    ///
    /// - Parameter aiLight: The assimp spot light.
    private func applySpotLightProperties(from aiLight: aiLight) {
        self.type = .spot
        let aiColor = aiLight.mColorSpecular
        debugPrint("Setting color: \(aiColor.r) \(aiColor.g) \(aiColor.b)")
        let space = CGColorSpaceCreateDeviceRGB()
        let components: [CGFloat] = [CGFloat(aiColor.r),
                                     CGFloat(aiColor.g),
                                     CGFloat(aiColor.b),
                                     1.0]
        if let cgColor = CGColor(colorSpace: space,
                                 components: components) {
            self.color = cgColor
        }
        if aiLight.mAttenuationQuadratic != 0 {
            self.attenuationFalloffExponent = 2.0
        }
        else if aiLight.mAttenuationLinear != 0 {
            self.attenuationFalloffExponent = 1.0
        }
        self.attenuationStartDistance = 0
        self.attenuationEndDistance = 0
        self.spotInnerAngle = CGFloat(aiLight.mAngleInnerCone)
        self.spotOuterAngle = CGFloat(aiLight.mAngleOuterCone)
    }
    
    
    /// Creates a scenekit ambient light from an assimp spot light.
    ///
    /// - Parameter aiLight: The assimp spot light.
    private func applyAmbientLightProperties(from aiLight: aiLight) {
        self.type = .ambient
        let aiColor = aiLight.mColorAmbient
        debugPrint("Setting color: \(aiColor.r) \(aiColor.g) \(aiColor.b)")
        let space = CGColorSpaceCreateDeviceRGB()
        let components: [CGFloat] = [CGFloat(aiColor.r),
                                     CGFloat(aiColor.g),
                                     CGFloat(aiColor.b),
                                     1.0]
        if let cgColor = CGColor(colorSpace: space,
                                 components: components) {
            self.color = cgColor
        }
    }
}

//
//  SCNMaterial+Extensions.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 30/11/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import SceneKit
import Assimp

extension SCNMaterial {
    
    @available(OSX 10.12, iOS 9.0, *)
    func loadBlendModeProperty(from aiMaterial: UnsafePointer<aiMaterial>) {
        debugPrint("Loading blend mode")
        var blendModeRawValue: Int32 = .zero
        var max: UInt32 = .max
        aiGetMaterialIntegerArray(aiMaterial,
                                  AI_MATKEY_BLEND_FUNC.pKey,
                                  AI_MATKEY_BLEND_FUNC.type,
                                  AI_MATKEY_BLEND_FUNC.index,
                                  &blendModeRawValue,
                                  &max)
        if blendModeRawValue == Int32(aiBlendMode_Default.rawValue) {
            debugPrint("Using alpha blend mode")
            self.blendMode = .alpha
        }
        else if blendModeRawValue == Int32(aiBlendMode_Additive.rawValue) {
            debugPrint("Using add blend mode")
            self.blendMode = .add
        }
    }
    
    func loadCullModeProperty(from aiMaterial: UnsafePointer<aiMaterial>) {
        debugPrint("Loading cull/double sided mode")
        var cullModeRawValue: Int32 = .zero
        var max: UInt32 = .max
        aiGetMaterialIntegerArray(aiMaterial,
                                  AI_MATKEY_TWOSIDED.pKey,
                                  AI_MATKEY_TWOSIDED.type,
                                  AI_MATKEY_TWOSIDED.index,
                                  &cullModeRawValue,
                                  &max)
        if cullModeRawValue == 1 {
            self.cullMode = .front
        } else {
            self.cullMode = .back
        }
    }
    
    func loadLightingModelProperty(from aiMaterial: UnsafePointer<aiMaterial>) {
        debugPrint("Loading lighting model")
        /**
         FIXME: The shading mode works only on iOS for iPhone.
         Does not work on iOS for iPad and OS X.
         Hence has been defaulted to Blinn.
         USE AI_MATKEY_SHADING_MODEL to get the shading mode.
         */
        var lightingModelRawValue: Int32 = .zero
        var max: UInt32 = .max
        aiGetMaterialIntegerArray(aiMaterial,
                                  AI_MATKEY_SHADING_MODEL.pKey,
                                  AI_MATKEY_SHADING_MODEL.type,
                                  AI_MATKEY_SHADING_MODEL.index,
                                  &lightingModelRawValue,
                                  &max)
        
        if lightingModelRawValue == Int32(aiShadingMode_Blinn.rawValue) {
            self.lightingModel = .blinn
        }
        if lightingModelRawValue == Int32(aiShadingMode_Minnaert.rawValue) {
            self.lightingModel = .lambert
        }
        if lightingModelRawValue == Int32(aiShadingMode_Phong.rawValue) {
            self.lightingModel = .phong
        }
        
    }
    
    /// Updates a scenekit material's multiply property
    ///
    /// - Parameter aiMaterial: The assimp material
    func loadMultiplyProperty(from aiMaterial: UnsafePointer<aiMaterial>) {
        debugPrint("Loading multiply color")
        var color = aiColor4D()
        color.r = 0.0
        color.g = 0.0
        color.b = 0.0
        let matColor = aiGetMaterialColor(aiMaterial,
                                          AI_MATKEY_COLOR_TRANSPARENT.pKey,
                                          AI_MATKEY_COLOR_TRANSPARENT.type,
                                          AI_MATKEY_COLOR_TRANSPARENT.index,
                                          &color).rawValue
        if aiReturn_SUCCESS.rawValue == matColor {
            let space = CGColorSpaceCreateDeviceRGB()
            let components: [CGFloat] = [CGFloat(color.r),
                                         CGFloat(color.g),
                                         CGFloat(color.b),
                                         CGFloat(color.a)]
            if let color = CGColor(colorSpace: space,
                                   components: components) {
                self.multiply.contents = Color(cgColor: color)
            }
        }
    }
    
    func loadShininessProperty(from aiMaterial: UnsafePointer<aiMaterial>) {
        debugPrint("Loading shininess")
        var shininessRawValue: Int32 = .zero
        var max: UInt32 = .max
        aiGetMaterialIntegerArray(aiMaterial,
                                  AI_MATKEY_SHININESS.pKey,
                                  AI_MATKEY_SHININESS.type,
                                  AI_MATKEY_SHININESS.index,
                                  &shininessRawValue,
                                  &max)
        debugPrint("shininess: \(shininessRawValue)")
        self.shininess = CGFloat(shininessRawValue)
    }
    
    func loadContentsProperties(from aiMaterial: UnsafeMutablePointer<aiMaterial>,
                                aiScene: aiScene,
                                path: String,
                                imageCache: AssimpImageCache) {
        let textureTypeTuple = [(value: aiTextureType_DIFFUSE,
                                 description: "Diffuse"),
                                (value: aiTextureType_SPECULAR,
                                 description: "Specular"),
                                (value: aiTextureType_AMBIENT,
                                 description: "Ambient"),
                                (value: aiTextureType_EMISSIVE,
                                 description: "Emissive"),
                                (value: aiTextureType_REFLECTION,
                                 description: "Reflection"),
                                (value: aiTextureType_OPACITY,
                                 description: "Opacity"),
                                (value: aiTextureType_NORMALS,
                                 description: "Normals"),
                                (value: aiTextureType_HEIGHT,
                                 description: "Height"),
                                (value: aiTextureType_DISPLACEMENT,
                                 description: "Displacement"),
                                (value: aiTextureType_SHININESS,
                                 description: "Shininess")]
        textureTypeTuple.forEach {
            debugPrint("Loading texture type : \($0.description)")
            let textureInfo = TextureInfo(aiMaterial: aiMaterial,
                                          textureType: $0.value,
                                          in: aiScene,
                                          at: path,
                                          imageCache: imageCache)
            self.makePropertyContents(with: textureInfo)
        }
    }
    
    /// Updates a scenekit material property with the texture file path or the color
    /// if no texture is specifed.
    ///
    /// - Parameter textureInfo: The metadata of the texture.
    private func makePropertyContents(with textureInfo: TextureInfo) {
        switch textureInfo.textureType {
        case aiTextureType_DIFFUSE:
            self.diffuse.contents = textureInfo.getMaterialPropertyContents()
            self.diffuse.mappingChannel = 0
            self.diffuse.wrapS = .repeat
            self.diffuse.wrapT = .repeat
            self.diffuse.intensity = 1
            self.diffuse.mipFilter = .linear
            self.diffuse.magnificationFilter = .linear
            self.diffuse.minificationFilter = .linear
        case aiTextureType_SPECULAR:
            self.specular.contents = textureInfo.getMaterialPropertyContents()
            self.specular.mappingChannel = 0
            self.specular.wrapS = .repeat
            self.specular.wrapT = .repeat
            self.specular.intensity = 1
            self.specular.mipFilter = .linear
            self.specular.magnificationFilter = .linear
            self.specular.minificationFilter = .linear
        case aiTextureType_AMBIENT:
            self.ambient.contents = textureInfo.getMaterialPropertyContents()
            self.ambient.mappingChannel = 0
            self.ambient.wrapS = .repeat
            self.ambient.wrapT = .repeat
            self.ambient.intensity = 1
            self.ambient.mipFilter = .linear
            self.ambient.magnificationFilter = .linear
            self.ambient.minificationFilter = .linear
        case aiTextureType_REFLECTION:
            self.reflective.contents = textureInfo.getMaterialPropertyContents()
            self.reflective.mappingChannel = 0
            self.reflective.wrapS = .repeat
            self.reflective.wrapT = .repeat
            self.reflective.intensity = 1
            self.reflective.mipFilter = .linear
            self.reflective.magnificationFilter = .linear
            self.reflective.minificationFilter = .linear
        case aiTextureType_EMISSIVE:
            self.emission.contents = textureInfo.getMaterialPropertyContents()
            self.emission.mappingChannel = 0
            self.emission.wrapS = .repeat
            self.emission.wrapT = .repeat
            self.emission.intensity = 1
            self.emission.mipFilter = .linear
            self.emission.magnificationFilter = .linear
            self.emission.minificationFilter = .linear
        case aiTextureType_OPACITY:
            self.transparent.contents = textureInfo.getMaterialPropertyContents()
            self.transparent.mappingChannel = 0
            self.transparent.wrapS = .repeat
            self.transparent.wrapT = .repeat
            self.transparent.intensity = 1
            self.transparent.mipFilter = .linear
            self.transparent.magnificationFilter = .linear
            self.transparent.minificationFilter = .linear
        case aiTextureType_NORMALS:
            self.normal.contents = textureInfo.getMaterialPropertyContents()
            self.normal.mappingChannel = 0
            self.normal.wrapS = .repeat
            self.normal.wrapT = .repeat
            self.normal.intensity = 1
            self.normal.mipFilter = .linear
            self.normal.magnificationFilter = .linear
            self.normal.minificationFilter = .linear
        case aiTextureType_HEIGHT:
            self.normal.contents = textureInfo.getMaterialPropertyContents()
            self.normal.mappingChannel = 0
            self.normal.wrapS = .repeat
            self.normal.wrapT = .repeat
            self.normal.intensity = 1
            self.normal.mipFilter = .linear
            self.normal.magnificationFilter = .linear
            self.normal.minificationFilter = .linear
        case aiTextureType_DISPLACEMENT:
            if #available(macOS 10.13, iOS 11.0, *) {
                self.displacement.contents = textureInfo.getMaterialPropertyContents()
                self.displacement.mappingChannel = 0
                self.displacement.wrapS = .repeat
                self.displacement.wrapT = .repeat
                self.displacement.intensity = 1
                self.displacement.mipFilter = .linear
                self.displacement.magnificationFilter = .linear
                self.displacement.minificationFilter = .linear
            }
        case aiTextureType_LIGHTMAP:
            if #available(macOS 10.12, iOS 9.0, *) {
                self.ambientOcclusion.contents = textureInfo.getMaterialPropertyContents()
                self.ambientOcclusion.mappingChannel = 0
                self.ambientOcclusion.wrapS = .repeat
                self.ambientOcclusion.wrapT = .repeat
                self.ambientOcclusion.intensity = 1
                self.ambientOcclusion.mipFilter = .linear
                self.ambientOcclusion.magnificationFilter = .linear
                self.ambientOcclusion.minificationFilter = .linear
            }
        default:
            break
        }
        
    }
    
}

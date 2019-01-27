//
//  SCNMaterial + TextureInfo.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 29/11/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import SceneKit
import assimp.types

extension SCNMaterial {
    
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
            print("Loading texture type : \($0.description)")
            let textureInfo = TextureInfo(aiMaterial: aiMaterial,
                                          textureType: $0.value,
                                          in: aiScene,
                                          atPath: path as NSString,
                                          imageCache: imageCache)
            makePropertyContents(with: textureInfo)
        }
    }
    
    /// Updates a scenekit material property with the texture file path or the color
    /// if no texture is specifed.
    ///
    /// - Parameter textureInfo: The metadata of the texture.
    private func makePropertyContents(with textureInfo: TextureInfo) {
        switch textureInfo.textureType {
        case aiTextureType_DIFFUSE:
            diffuse.contents = textureInfo.getMaterialPropertyContents()
            diffuse.mappingChannel = 0
            diffuse.wrapS = .repeat
            diffuse.wrapT = .repeat
            diffuse.intensity = 1
            diffuse.mipFilter = .linear
            diffuse.magnificationFilter = .linear
            diffuse.minificationFilter = .linear
        case aiTextureType_SPECULAR:
            specular.contents = textureInfo.getMaterialPropertyContents()
            specular.mappingChannel = 0
            specular.wrapS = .repeat
            specular.wrapT = .repeat
            specular.intensity = 1
            specular.mipFilter = .linear
            specular.magnificationFilter = .linear
            specular.minificationFilter = .linear
        case aiTextureType_AMBIENT:
            ambient.contents = textureInfo.getMaterialPropertyContents()
            ambient.mappingChannel = 0
            ambient.wrapS = .repeat
            ambient.wrapT = .repeat
            ambient.intensity = 1
            ambient.mipFilter = .linear
            ambient.magnificationFilter = .linear
            ambient.minificationFilter = .linear
        case aiTextureType_REFLECTION:
            reflective.contents = textureInfo.getMaterialPropertyContents()
            reflective.mappingChannel = 0
            reflective.wrapS = .repeat
            reflective.wrapT = .repeat
            reflective.intensity = 1
            reflective.mipFilter = .linear
            reflective.magnificationFilter = .linear
            reflective.minificationFilter = .linear
        case aiTextureType_EMISSIVE:
            emission.contents = textureInfo.getMaterialPropertyContents()
            emission.mappingChannel = 0
            emission.wrapS = .repeat
            emission.wrapT = .repeat
            emission.intensity = 1
            emission.mipFilter = .linear
            emission.magnificationFilter = .linear
            emission.minificationFilter = .linear
        case aiTextureType_OPACITY:
            transparent.contents = textureInfo.getMaterialPropertyContents()
            transparent.mappingChannel = 0
            transparent.wrapS = .repeat
            transparent.wrapT = .repeat
            transparent.intensity = 1
            transparent.mipFilter = .linear
            transparent.magnificationFilter = .linear
            transparent.minificationFilter = .linear
        case aiTextureType_NORMALS:
            normal.contents = textureInfo.getMaterialPropertyContents()
            normal.mappingChannel = 0
            normal.wrapS = .repeat
            normal.wrapT = .repeat
            normal.intensity = 1
            normal.mipFilter = .linear
            normal.magnificationFilter = .linear
            normal.minificationFilter = .linear
        case aiTextureType_HEIGHT:
            normal.contents = textureInfo.getMaterialPropertyContents()
            normal.mappingChannel = 0
            normal.wrapS = .repeat
            normal.wrapT = .repeat
            normal.intensity = 1
            normal.mipFilter = .linear
            normal.magnificationFilter = .linear
            normal.minificationFilter = .linear
        case aiTextureType_DISPLACEMENT:
            normal.contents = textureInfo.getMaterialPropertyContents()
            normal.mappingChannel = 0
            normal.wrapS = .repeat
            normal.wrapT = .repeat
            normal.intensity = 1
            normal.mipFilter = .linear
            normal.magnificationFilter = .linear
            normal.minificationFilter = .linear
        case aiTextureType_LIGHTMAP:
            if #available(OSX 10.12, iOS 9.0, *) {
                ambientOcclusion.contents = textureInfo.getMaterialPropertyContents()
                ambientOcclusion.mappingChannel = 0
                ambientOcclusion.wrapS = .repeat
                ambientOcclusion.wrapT = .repeat
                ambientOcclusion.intensity = 1
                ambientOcclusion.mipFilter = .linear
                ambientOcclusion.magnificationFilter = .linear
                ambientOcclusion.minificationFilter = .linear
            } else {
               break
            }
        default:
            break
        }
        
    }
    
}

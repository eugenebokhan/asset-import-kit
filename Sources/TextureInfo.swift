//
//  SCNTextureInfo.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 2/11/18.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import Foundation
import ImageIO
import CoreImage
import Assimp

#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

public class TextureInfo {
    
    // MARK: - Texture metadata
    
    /// The texture type: diffuse, specular etc.
    var textureType: aiTextureType?
    
    // MARK: - Texture material
    
    /// The material name which is the owner of this texture.
    var materialName: String = ""
    
    // MARK: - Texture color and resources
    
    /// A Boolean value that determines whether a color is applied to a material
    /// property.
    var applyColor: Bool = false {
        didSet {
            if self.applyColor {
                self.applyEmbeddedTexture = false
                self.applyExternalTexture = false
            }
        }
    }
    
    /// The actual color to be applied to a material property.
    var color: Color?
    
    /// A profile that specifies the interpretation of a color to be applied to
    /// a material property.
    var colorSpace: CGColorSpace?
    
    // MARK: - Embedded texture
    
    /// A Boolean value that determines if embedded texture is applied to a
    // material property.
    var applyEmbeddedTexture: Bool = false {
        didSet {
            if self.applyEmbeddedTexture {
                self.applyColor = false
                self.applyExternalTexture = false
            }
        }
    }
    
    /// The index of the embedded texture in the array of assimp scene textures.
    var embeddedTextureIndex: Int?
    
    // MARK: - External texture
    
    /// A Boolean value that determines if an external texture is applied to a
    /// material property.
    var applyExternalTexture: Bool = false {
        didSet {
            if applyExternalTexture {
                self.applyColor = false
                self.applyEmbeddedTexture = false
            }
        }
    }
    
    /// The path to the external texture resource on the disk.
    var externalTexturePath: String?
    
    // MARK: - Texture image resources
    
    /// An opaque type that represents the external texture image source.
    var imageSource: CGImageSource?
    
    /// An abstraction for the raw image data of an embedded texture image source that
    /// eliminates the need to manage raw memory buffer.
    var imageDataProvider: CGDataProvider?
    
    /// A bitmap image representing either an external or embedded texture applied to
    /// a material property.
    var image: CGImage?
    
    
    // MARK: - Creating a texture info
    
    /// Create a texture metadata object for a material property.
    ///
    /// - Parameters:
    ///   - aiMaterial: The index of the mesh to which this texture is applied.
    ///   - aiTextureType: The texture type: diffuse, specular etc.
    ///   - aiScene: The assimp scene.
    ///   - path: The path to the scene file to load.
    ///   - imageCache: A new texture info.
    init(aiMaterial: UnsafeMutablePointer<aiMaterial>,
         textureType aiTextureType: aiTextureType,
         in aiScene: aiScene,
         at path: String,
         imageCache: AssimpImageCache) {
        
        self.imageSource = nil
        self.imageDataProvider = nil
        self.image = nil
        self.colorSpace = nil
        self.color = nil
        
        self.textureType = aiTextureType
        self.materialName = aiMaterial.pointee.name
        
        self.checkTextureType(for: aiMaterial,
                              with: aiTextureType,
                              in: aiScene,
                              atPath: path,
                              imageCache: imageCache)
    }
    
    
    // MARK: - Inspect texture metadata
    
    /// Inspects the material texture properties to determine if color, embedded
    /// texture or external texture should be applied to the material property.
    ///
    /// - Parameters:
    ///   - aiMaterial: The assimp material.
    ///   - aiTextureType: The material property: diffuse, specular etc.
    ///   - aiScene: The assimp scene.
    ///   - path: The path to the scene file to load.
    ///   - imageCache: The texture image cache.
    func checkTextureType(for aiMaterial: UnsafeMutablePointer<aiMaterial>,
                          with aiTextureType: aiTextureType,
                          in aiScene: aiScene,
                          atPath path: String,
                          imageCache: AssimpImageCache) {
        let nTextures = aiGetMaterialTextureCount(aiMaterial,
                                                  aiTextureType)
        debugPrint("has textures: \(nTextures)")
        debugPrint("has embedded textures: \(aiScene.mNumTextures)")
        if nTextures == 0 && aiScene.mNumTextures == 0 {
            self.applyColor = true
            self.extractColor(for: aiMaterial,
                              with: aiTextureType)
        } else {
            if nTextures == 0 {
                self.applyColor = true
                self.extractColor(for: aiMaterial,
                                  with: aiTextureType)
            } else {
                var aiPath = aiString()
                aiGetMaterialTexture(aiMaterial,
                                     aiTextureType,
                                     UInt32(0),
                                     &aiPath,
                                     nil,
                                     nil,
                                     nil,
                                     nil,
                                     nil,
                                     nil)
                // Fix file path
                var texFilePath = aiPath.stringValue() as NSString
                texFilePath = texFilePath.replacingOccurrences(of: "\\\\",
                                                               with: "/") as NSString
                texFilePath = texFilePath.replacingOccurrences(of: "\\",
                                                               with: "/") as NSString
                
                let texFileName = texFilePath.lastPathComponent
                if texFileName == "" {
                    self.applyColor = true
                    self.extractColor(for: aiMaterial,
                                      with: aiTextureType)
                } else if texFileName.count > 0  && aiScene.mNumTextures > 0 {
                    self.applyEmbeddedTexture = true
                    if (texFileName.hasPrefix("*")) {
                        if let embeddedTextureIndex = Int((texFilePath.substring(from: 1))) {
                            self.embeddedTextureIndex = embeddedTextureIndex
                        }
                    }
                    if let embeddedTextureIndex = self.embeddedTextureIndex {
                        if embeddedTextureIndex >= Int(aiScene.mNumTextures) {
                            debugPrint("ERROR: Embedded texture index: \(embeddedTextureIndex) is out of bounds (0..\((aiScene.mNumTextures - 1))")
                            self.embeddedTextureIndex = Int(aiScene.mNumTextures) - 1;
                        }
                        debugPrint("Embedded texture index: \(embeddedTextureIndex)")
                        if let cachedImage = imageCache.cachedFileAtPath(path: texFilePath as String) {
                            self.image = cachedImage
                        } else {
                            self.generateCGImageForEmbeddedTexture(at: embeddedTextureIndex,
                                                                   in: aiScene)
                            if let image = self.image {
                                imageCache.storeImage(image: image,
                                                      toPath: texFilePath as String)
                            }
                        }
                    }
                } else {
                    self.applyExternalTexture = true
                    debugPrint("tex file name is \(String(describing: texFileName))")
                    let sceneDir = ((path as NSString).deletingLastPathComponent).appending("/")
                    self.externalTexturePath = sceneDir.appending(texFileName)
                    if let externalTexturePath = self.externalTexturePath {
                        debugPrint("tex path is \(externalTexturePath)")
                        self.generateCGImageForExternalTexture(atPath: externalTexturePath,
                                                               imageCache: imageCache)
                    }
                }
            }
        }
    }
    
    // MARK: - Generate textures
    
    /// Generates a bitmap image representing the embedded texture.
    ///
    /// - Parameters:
    ///   - index: The index of the texture in assimp scene's textures.
    ///   - aiScene: The assimp scene.
    func generateCGImageForEmbeddedTexture(at index: Int,
                                           in aiScene: aiScene) {
        debugPrint("Generating embedded texture")
        if let aiTexturePointer = aiScene.mTextures[index] {
            let aiTexture = aiTexturePointer.pointee
            let data = aiTexture.pcData
            let mWidth = aiTexture.mWidth
            let imageData = NSData(bytes: data,
                                   length: Int(mWidth))
            self.imageDataProvider = CGDataProvider(data: imageData)
            let format = tupleOfInt8sToString(aiTexture.achFormatHint)
            if format == "png" {
                debugPrint("Created png embedded texture")
                self.image = CGImage(pngDataProviderSource: self.imageDataProvider!,
                                     decode: nil,
                                     shouldInterpolate: true,
                                     intent: .defaultIntent)
            }
            if format == "jpg" {
                debugPrint("Created jpg embedded texture")
                self.image = CGImage(jpegDataProviderSource: self.imageDataProvider!,
                                     decode: nil,
                                     shouldInterpolate: true,
                                     intent: .defaultIntent)
            }
        } else {
            self.image = nil
        }
        
    }
    
    /// Generates a bitmap image representing the external texture.
    ///
    /// - Parameters:
    ///   - path: The path to the scene file to load.
    ///   - imageCache: The texture image cache.
    func generateCGImageForExternalTexture(atPath path: String,
                                           imageCache: AssimpImageCache) {
        if let cachedImage = imageCache.cachedFileAtPath(path: path) {
            debugPrint("Already generated this texture, using from cache")
            self.image = cachedImage
        } else {
            debugPrint("Generating external texture")
            let imageURL = NSURL.fileURL(withPath: path as String)
            if let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL,
                                                            nil) {
                self.imageSource = imageSource
                self.image = CGImageSourceCreateImageAtIndex(imageSource,
                                                             0,
                                                             nil)
            } else {
                debugPrint("ERROR: Unable to find \(imageURL.lastPathComponent) at \(imageURL.deletingLastPathComponent())")
            }
        }
        if let image = self.image {
            imageCache.storeImage(image: image,
                                  toPath: (path as String))
        }
    }
    
    
    // MARK: - Extract color
    
    func extractColor(for aiMaterial: UnsafeMutablePointer<aiMaterial>,
                                      with aiTextureType: aiTextureType) {
        debugPrint("Extracting color")
        var color = aiColor4D()
        color.r = 0.0
        color.g = 0.0
        color.b = 0.0
        var matColor: aiReturn = aiReturn(rawValue: -100)
        if aiTextureType == aiTextureType_DIFFUSE {
            matColor = aiGetMaterialColor(aiMaterial,
                                          AI_MATKEY_COLOR_DIFFUSE.pKey,
                                          AI_MATKEY_COLOR_DIFFUSE.type,
                                          AI_MATKEY_COLOR_DIFFUSE.index,
                                          &color)
        }
        if(aiTextureType == aiTextureType_SPECULAR) {
            matColor = aiGetMaterialColor(aiMaterial,
                                          AI_MATKEY_COLOR_SPECULAR.pKey,
                                          AI_MATKEY_COLOR_SPECULAR.type,
                                          AI_MATKEY_COLOR_SPECULAR.index,
                                          &color)
        }
        if(aiTextureType == aiTextureType_AMBIENT) {
            matColor = aiGetMaterialColor(aiMaterial,
                                          AI_MATKEY_COLOR_AMBIENT.pKey,
                                          AI_MATKEY_COLOR_AMBIENT.type,
                                          AI_MATKEY_COLOR_AMBIENT.index,
                                          &color)
        }
        if(aiTextureType == aiTextureType_REFLECTION) {
            matColor = aiGetMaterialColor(aiMaterial,
                                          AI_MATKEY_COLOR_REFLECTIVE.pKey,
                                          AI_MATKEY_COLOR_REFLECTIVE.type,
                                          AI_MATKEY_COLOR_REFLECTIVE.index,
                                          &color)
        }
        if(aiTextureType == aiTextureType_EMISSIVE) {
            matColor = aiGetMaterialColor(aiMaterial,
                                          AI_MATKEY_COLOR_EMISSIVE.pKey,
                                          AI_MATKEY_COLOR_EMISSIVE.type,
                                          AI_MATKEY_COLOR_EMISSIVE.index,
                                          &color)
        }
        if(aiTextureType == aiTextureType_OPACITY) {
            matColor = aiGetMaterialColor(aiMaterial,
                                          AI_MATKEY_COLOR_TRANSPARENT.pKey,
                                          AI_MATKEY_COLOR_TRANSPARENT.type,
                                          AI_MATKEY_COLOR_TRANSPARENT.index,
                                          &color)
        }
        if aiReturn_SUCCESS == matColor {
            self.colorSpace = CGColorSpaceCreateDeviceRGB()
            let components: [CGFloat] = [CGFloat(color.r),
                                         CGFloat(color.g),
                                         CGFloat(color.b),
                                         CGFloat(color.a)]
            if let colorSpace = self.colorSpace,
                let cgColor = CGColor(colorSpace: colorSpace,
                                      components: components) {
                self.color = Color(cgColor: cgColor)
            }
        }
        
    }
    
    // MARK: - Texture resources
    
    /// Returns the color or the bitmap image to be applied to the material property.
    ///
    /// - Returns: Returns either a color or a bitmap image.
    func getMaterialPropertyContents() -> Any? {
        return (self.applyEmbeddedTexture || self.applyExternalTexture) ? self.image : self.color
    }
    
    /// Releases the graphics resources used to generate color or bitmap image to be
    /// applied to a material property.
    ///
    /// This method must be called by the client to avoid memory leaks!
    func releaseContents() {
        self.imageSource = nil
        self.imageDataProvider = nil
        self.image = nil
        self.colorSpace = nil
        self.color = nil
    }
    
}


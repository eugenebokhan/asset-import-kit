//
//  SCNScene+Extensions.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 2/11/18.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import SceneKit
import Assimp

/**
 A scenekit SCNScene category to import scenes using the assimp library.
 */
public extension SCNScene {
    
    // MARK: - Loading scenes using assimp
    
    /// Loading scenes using assimp
    ///
    /// - Returns: Returns the array of file extensions for all the supported formats.
    static func allowedFileExtensions() -> [String] {
        return ["dae", "fbx", "obj", "scn", "md3", "zgl", "xgl", "wrl", "stl", "smd", "raw", "q3s", "q3o", "ply", "xml", "mesh", "off", "nff", "m3sd", "md5anim", "md5mesh", "md2", "irr", "ifc", "dxf", "cob", "bvh", "b3d", "blend", "hmp", "3ds", "3d",  "ms3d", "mdl", "ase", "gltf"]
    }
    
    /// Returns a Boolean value that indicates whether the SCNAssimpScene class can
    /// read asset data from files with the specified extension.
    ///
    /// - Parameter extension: The filename extension identifying an asset file format.
    /// - Returns: YES if the SCNAssimpScene class can read asset data from files with
    /// the specified extension; otherwise, NO.
    static func canImportFileExtension(_ extension: String) -> Bool {
        return allowedFileExtensions().contains(`extension`.lowercased())
    }
    
    /// Loads a scene from a file with the specified name in the app’s main bundle.
    ///
    /// - Parameters:
    ///   - filePath: The name of a scene file to load.
    ///   - postProcessSteps: The flags for all possible post processing steps.
    /// - Returns: A new scene object, or nil if no scene could be loaded.
    /// - Throws: Scene loading error.
    static func assimpScene(filePath: String,
                            postProcessSteps: PostProcessSteps) throws -> AssetImporterScene {
        return try AssetImporter().importScene(filePath: filePath,
                                               postProcessSteps: postProcessSteps)
    }
    
    /// Loads a scene from the specified NSString URL.
    ///
    /// - Parameters:
    ///   - url: The URL to the scene file to load.
    ///   - postProcessSteps: The flags for all possible post processing steps.
    /// - Returns: A new scene object, or nil if no scene could be loaded.
    /// - Throws: Scene loading error.
    static func assimpScene(with url: URL,
                            postProcessSteps: PostProcessSteps) throws -> AssetImporterScene {
        return try AssetImporter().importScene(filePath: url.path,
                                               postProcessSteps: postProcessSteps)
    }
    
    /// Creates an array of scenekit bone nodes for the specified bone names.
    ///
    /// - Parameter boneNames: The array of bone names.
    /// - Returns: An array of scenekit bone nodes.
    func getBoneNodes(for boneNames: [String]) -> [SCNNode] {
        var boneNodes: [SCNNode] = []
        for boneName in boneNames {
            if let boneNode = rootNode.childNode(withName: boneName,
                                                 recursively: true) {
                boneNodes.append(boneNode)
            }
        }
        return boneNodes
    }
    
}


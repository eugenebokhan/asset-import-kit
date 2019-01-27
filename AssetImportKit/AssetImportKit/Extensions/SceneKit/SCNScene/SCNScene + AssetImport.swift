//
//  SCNScene+AssetImport.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 2/11/18.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import SceneKit

enum SceneLoadingErrors: Error {
    case noFileExists
}

/**
 A scenekit SCNScene category to import scenes using the assimp library.
 */
public extension SCNScene {
    
    // MARK: - Loading scenes using assimp
    
    /// Loading scenes using assimp
    ///
    /// - Returns: Returns the array of file extensions for all the supported formats.
    public static func allowedFileExtensions() -> [String] {
        return ["dae", "fbx", "obj", "scn", "md3", "zgl", "xgl", "wrl", "stl", "smd", "raw", "q3s", "q3o", "ply", "xml", "mesh", "off", "nff", "m3sd", "md5anim", "md5mesh", "md2", "irr", "ifc", "dxf", "cob", "bvh", "b3d", "blend", "hmp", "3ds", "3d",  "ms3d", "mdl", "ase", "gltf"]
    }
    
    /// Returns a Boolean value that indicates whether the SCNAssimpScene class can
    /// read asset data from files with the specified extension.
    ///
    /// - Parameter extension: The filename extension identifying an asset file format.
    /// - Returns: YES if the SCNAssimpScene class can read asset data from files with
    /// the specified extension; otherwise, NO.
    public static func canImportFileExtension(_ extension: String) -> Bool {
        return allowedFileExtensions().contains(`extension`.lowercased())
    }
    
    /// Loads a scene from a file with the specified name in the app’s main bundle.
    ///
    /// - Parameters:
    ///   - filePath: The name of a scene file in the app bundle’s resources directory.
    ///   - postProcessSteps: The flags for all possible post processing steps.
    /// - Returns: A new scene object, or nil if no scene could be loaded.
    /// - Throws: Scene loading error.
    public static func assimpScene(filePath: String,
                                   postProcessSteps: PostProcessSteps) throws -> AssetImporterScene {
        do {
            var assimpImporter = AssetImporter()
            let scene = try assimpImporter.importScene(filePath: filePath,
                                                       postProcessSteps: postProcessSteps)
            return scene
        } catch {
            throw error
        }
    }
    
    /// Loads a scene from the specified NSString URL.
    ///
    /// - Parameters:
    ///   - url: The NSString URL to the scene file to load.
    ///   - postProcessSteps: The flags for all possible post processing steps.
    /// - Returns: A new scene object, or nil if no scene could be loaded.
    /// - Throws: Scene loading error.
    public static func assimpScene(with url: URL,
                                   postProcessSteps: PostProcessSteps) throws -> AssetImporterScene {
        do {
            let scene = try assimpScene(with: url, postProcessSteps: postProcessSteps)
            return scene
        } catch {
            throw error
        }
    }
    
}


//
//  aiNode + makeGeometrySources.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 02/12/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import SceneKit
import assimp.scene

extension aiNode {
    
    /// Creates an array of geometry sources for the specifed node describing
    /// the vertices in the geometry and their attributes.
    ///
    /// - Parameter aiScene: The assimp scene.
    /// - Returns: An array of geometry sources.
    func makeGeometrySources(from aiScene: aiScene) -> [SCNGeometrySource] {
        var scnGeometrySources: [SCNGeometrySource] = []
        scnGeometrySources.append(makeVertexGeometrySource(from: aiScene))
        scnGeometrySources.append(makeNormalGeometrySource(from: aiScene))
        scnGeometrySources.append(makeTextureGeometrySource(from: aiScene))
        if #available(OSX 10.12, iOS 10.0, *) {
            scnGeometrySources.append(makeTangentGeometrySource(from: aiScene))
        }
        if let colorGeometrySource = makeColorGeometrySource(from: aiScene) {
            scnGeometrySources.append(colorGeometrySource)
        }
        return scnGeometrySources
    }
    
}

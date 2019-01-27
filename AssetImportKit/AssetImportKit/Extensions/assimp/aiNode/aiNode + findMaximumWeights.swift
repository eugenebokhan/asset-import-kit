//
//  aiNode + findMaximumWeights.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 01/12/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import assimp.scene

extension aiNode {
    
    /// Finds the maximum number of weights that influence the vertices in the meshes
    /// of the specified node.
    ///
    /// - Parameter aiScene: The assimp scene.
    /// - Returns: The maximum influences or weights.
    func findMaximumWeights(in aiScene: aiScene) -> Int {
        var maxWeights: Int = 0
        let aiNodeMeshes = getMeshes(from: aiScene)
        for aiMesh in aiNodeMeshes {
            var aiMeshWeights: [UInt32 : Int] = [ : ]
            let aiMeshBones = aiMesh.getBones()
            for aiBone in aiMeshBones {
                let aiBoneVertexWeights = aiBone.getVertexWeights()
                for aiVertexWeight in aiBoneVertexWeights {
                    let vertexID = aiVertexWeight.mVertexId
                    aiMeshWeights[vertexID] = aiMeshWeights[vertexID] == nil ? 1 : aiMeshWeights[vertexID]! + 1
                }
            }
            // Find the vertex with most weights which is our max weights
            for i in 0 ..< aiMesh.mNumVertices {
                if let weightsCount = aiMeshWeights[i] {
                    if weightsCount > maxWeights {
                        maxWeights = weightsCount
                    }
                }
            }
        }
        return maxWeights
    }
    
}

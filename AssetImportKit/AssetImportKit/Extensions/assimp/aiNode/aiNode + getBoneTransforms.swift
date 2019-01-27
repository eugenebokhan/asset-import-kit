//
//  aiNode + getBoneTransforms.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 03/12/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import GLKit
import SceneKit
import assimp.scene

extension aiNode {
    
    /// Creates a dictionary of bone transforms where bone name is the key, for the
    /// meshes of the specified node.
    ///
    /// - Parameter aiScene: The assimp scene.
    /// - Returns: A dictionary of bone transforms where bone name is the key.
    func getBoneTransforms(in aiScene: aiScene) -> [String : SCNMatrix4] {
        var boneTransforms: [String : SCNMatrix4] = [:]
        let aiSceneMeshes = aiScene.getMeshes()
        for aiMesh in aiSceneMeshes {
            let aiMeshBones = aiMesh.getBones()
            for aiBone in aiMeshBones {
                let key = aiBone.mName.stringValue()
                let aiNodeMatrix = aiBone.mOffsetMatrix
                let glkBoneMatrix = GLKMatrix4(m: (aiNodeMatrix.a1, aiNodeMatrix.b1, aiNodeMatrix.c1, aiNodeMatrix.d1,
                                                   aiNodeMatrix.a2, aiNodeMatrix.b2, aiNodeMatrix.c2, aiNodeMatrix.d2,
                                                   aiNodeMatrix.a3, aiNodeMatrix.b3, aiNodeMatrix.c3, aiNodeMatrix.d3,
                                                   aiNodeMatrix.a4, aiNodeMatrix.b4, aiNodeMatrix.c4, aiNodeMatrix.d4))
                let scnMatrix = SCNMatrix4FromGLKMatrix4(glkBoneMatrix)
                boneTransforms[key] = scnMatrix
            }
        }
        return boneTransforms
    }
    
}

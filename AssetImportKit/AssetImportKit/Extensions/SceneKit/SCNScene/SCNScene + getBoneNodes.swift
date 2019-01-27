//
//  SCNScene + getBoneNodes.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 03/12/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import SceneKit

extension SCNScene {
    
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

//
//  SCNNode + findDepth.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 03/12/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import SceneKit

extension SCNNode {
    
    /// Finds the depth of the specified node from the scene's root node.
    ///
    /// - Returns: The depth from the scene's root node.
    func findDepth() -> Int {
        var depth: Int = 0
        var parentNode = self
        while (parentNode.parent != nil) {
            depth += 1
            parentNode = parentNode.parent!
        }
        return depth
    }
    
}

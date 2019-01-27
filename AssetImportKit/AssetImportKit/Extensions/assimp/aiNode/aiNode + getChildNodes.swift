//
//  aiNode + getChildNodes.swift
//  AssetImportKit-iOS
//
//  Created by Eugene Bokhan on 02/12/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import assimp.scene

extension aiNode {
    
    func getChildNodes() -> [aiNode] {
        let childNodesCount = Int(mNumChildren)
        let childNodes = Array(UnsafeBufferPointer(start: mChildren,
                                                    count: childNodesCount)).map { $0!.pointee }
        
        return childNodes
    }
    
}



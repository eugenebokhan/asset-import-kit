//
//  AssimpImageCache.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 28/11/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import ImageIO
import Assimp

class AssimpImageCache {
    
    var cacheDictionary: [String : CGImage] = [:]
    
    func cachedFileAtPath(path: String) -> CGImage? {
        return cacheDictionary[path]
    }
    
    func storeImage(image: CGImage, toPath: String) {
        cacheDictionary[toPath] = image
    }
    
}

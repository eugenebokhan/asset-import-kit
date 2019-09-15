//
//  aiString+Extensions.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 30/11/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import Assimp

func tupleOfInt8sToString( _ tupleOfInt8s: Any) -> NSString {
    var result = ""
    let mirror = Mirror(reflecting: tupleOfInt8s)
    for child in mirror.children {
        if let characterValue = child.value as? Int8,
            characterValue != 0 {
            result.append(Character(UnicodeScalar(UInt8(abs(characterValue)))))
        }
    }
    return result as NSString
}

extension aiString {
    
    func stringValue() -> String {
        var arrayOfInt8: [Int8] {
            var tmp = self
            return [Int8](UnsafeBufferPointer(start: &tmp.data.0,
                                              count: MemoryLayout.size(ofValue: tmp.data)))
        }
        return String(utf8String: arrayOfInt8) ?? ""
    }
    
}

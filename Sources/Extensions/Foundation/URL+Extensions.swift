//
//  URL+Extensions.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 12/01/2019.
//  Copyright © 2019 Eugene Bokhan. All rights reserved.
//

import Foundation

extension URL {
    
    public var fileExists: Bool {
        return FileManager.default.fileExists(atPath: (self.path))
    }
    
}

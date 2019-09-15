//
//  DebugdebugPrint.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 15.09.2019.
//

import Foundation

func debugdebugPrint(_ string: String) {
    #if DEBUG
    debugPrint(string)
    #endif
}

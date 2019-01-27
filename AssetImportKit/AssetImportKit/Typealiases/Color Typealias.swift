//
//  Color Typealias.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 30/11/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
public typealias Color = UIColor
#elseif os(OSX)
import AppKit
public typealias Color = NSColor
#endif

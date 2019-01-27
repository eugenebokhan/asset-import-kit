//
//  FileBrowser.swift
//  3DViewer
//
//  Created by Eugene Bokhan on 9/14/17.
//  Copyright © 2017 Eugene Bokhan. All rights reserved.
//

import Foundation
import UIKit

// File browser containing navigation controller.
open class FileBrowser: UINavigationController {
    
    // MARK: - Properties
    
    let parser = FileParser.sharedInstance
    
    var fileList: FileListViewController?
    
    // MARK: - Properties
    static var inARmode = false
    
    // File types to exclude from the file browser.
    open var excludesFileExtensions: [String]? {
        didSet {
            parser.excludesFileExtensions = excludesFileExtensions
        }
    }
    
    // File paths to exclude from the file browser.
    open var excludesFilepaths: [URL]? {
        didSet {
            parser.excludesFilepaths = excludesFilepaths
        }
    }
    
    // Override default preview and actionsheet behaviour in favour of custom file handling.
    open var didSelectFile: ((FBFile) -> ())? {
        didSet {
            fileList?.didSelectFile = didSelectFile
        }
    }
    
    // MARK: - Lyfecycle
    
    public convenience init() {
        let parser = FileParser.sharedInstance
        let path = parser.documentsURL()
        self.init(initialPath: path, allowEditing: true)
    }
    
    // Initialise file browser.
    //
    //   - Parameters:
    //   - initialPath: NSURL filepath to containing directory.
    //   - allowEditing: Whether to allow editing.
    //   - showCancelButton: Whether to show the cancel button.
    public convenience init(initialPath: URL = FileParser.sharedInstance.documentsURL(), allowEditing: Bool = true, showCancelButton: Bool = true) {
        let fileListViewController = FileListViewController(initialPath: initialPath, showCancelButton: showCancelButton)
        fileListViewController.allowEditing = allowEditing
        self.init(rootViewController: fileListViewController)
        self.view.backgroundColor = #colorLiteral(red: 0.3490196078, green: 0.3490196078, blue: 0.3490196078, alpha: 1)
        self.fileList = fileListViewController
    }
    
}


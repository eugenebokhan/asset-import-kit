//
//  PreviewManager.swift
//  3DViewer
//
//  Created by Eugene Bokhan on 9/14/17.
//  Copyright © 2017 Eugene Bokhan. All rights reserved.
//

import Foundation
import UIKit
import QuickLook

class PreviewManager: NSObject, QLPreviewControllerDataSource {
    
    // MARK: - Properties
    
    var filePath: URL?
    
    // MARK: - Methods
    
    func previewViewControllerForFile(_ file: FBFile, fromNavigation: Bool) -> UIViewController {
        
        if file.type == .PLIST || file.type == .JSON {
            let webviewPreviewViewContoller = WebviewPreviewViewContoller()
            webviewPreviewViewContoller.file = file
            return webviewPreviewViewContoller
        }
        if file.type == .DAE || file.type == .FBX || file.type == .OBJ || file.type == .SCN || file.type == .MD3 || file.type == .ZGL || file.type == .XGL || file.type == .WRL || file.type == .STL || file.type == .SMD || file.type == .RAW || file.type == .Q3S || file.type == .Q3O || file.type == .PLY || file.type == .XML || file.type == .MESH || file.type == .OFF || file.type == .NFF || file.type == .M3SD || file.type == .MD5ANIM || file.type == .MD5MESH || file.type == .MD2 || file.type == .IRR || file.type == .IFC || file.type == .DXF || file.type == .COB || file.type == .BVH || file.type == .B3D || file.type == .AC || file.type == .BLEND || file.type == .HMP || file.type == ._3DS || file.type == ._3D || file.type == .X || file.type == .TER || file.type == .MAX || file.type == .MS3D || file.type == .MDL || file.type == .ASE || file.type == .GLTF {
            let sceneViewController = ScenePreviewViewContoller()
            sceneViewController.file = file
            return sceneViewController
        }
        else {
            let previewTransitionViewController = PreviewTransitionViewController()
            previewTransitionViewController.quickLookPreviewController.dataSource = self
            
            self.filePath = file.filePath as URL
            if fromNavigation == true {
                return previewTransitionViewController.quickLookPreviewController
            }
            return previewTransitionViewController
        }
    }
    
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let item = PreviewItem()
        if let filePath = filePath {
            item.filePath = filePath
        }
        return item
    }
    
}

class PreviewItem: NSObject, QLPreviewItem {
    
    /*!
     * @abstract The URL of the item to preview.
     * @discussion The URL must be a file URL.
     */
    
    var filePath: URL?
    public var previewItemURL: URL? {
        if let filePath = filePath {
            return filePath
        }
        return nil
    }
    
}

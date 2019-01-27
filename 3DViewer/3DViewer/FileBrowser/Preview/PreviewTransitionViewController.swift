//
//  PreviewTransitionViewController.swift
//  3DViewer
//
//  Created by Eugene Bokhan on 9/14/17.
//  Copyright © 2017 Eugene Bokhan. All rights reserved.
//

import UIKit
import QuickLook

class PreviewTransitionViewController: UIViewController {
    
    // MARK: - Properties
    
    let quickLookPreviewController = QLPreviewController()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addChild(quickLookPreviewController)
        view.addSubview(quickLookPreviewController.view)
        quickLookPreviewController.view.frame = view.bounds
        quickLookPreviewController.didMove(toParent: self)
    }
}


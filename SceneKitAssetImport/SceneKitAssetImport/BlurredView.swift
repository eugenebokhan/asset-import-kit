//
//  BlurredView.swift
//  SceneKitAssetImport
//
//  Created by Eugene Bokhan on 2/12/18.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import Foundation
import Cocoa

class BlurredView: NSVisualEffectView {
    
    override func viewDidMoveToWindow() {
        self.material = NSVisualEffectView.Material.mediumLight
        self.blendingMode = NSVisualEffectView.BlendingMode.behindWindow
        self.state = NSVisualEffectView.State.active
    }
    
}

//
//  ARCameraTrackingState.swift
//  3DViewer
//
//  Created by Eugene Bokhan on 2/1/18.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import Foundation
import ARKit

extension ARCamera.TrackingState {
    var presentationString: String {
        switch self {
        case .notAvailable:
            return "TRACKING UNAVAILABLE"
        case .normal:
            return "TRACKING NORMAL"
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                return "TRACKING LIMITED\nToo much camera movement"
            case .insufficientFeatures:
                return "TRACKING LIMITED\nNot enough surface detail"
            case .initializing:
                return "Init"
            case .relocalizing:
                return "Relocate"
            }
        }
    }
}


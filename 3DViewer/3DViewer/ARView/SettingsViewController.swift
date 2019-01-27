//
//  SettingsViewController.swift
//  3DViewer
//
//  Created by Eugene Bokhan on 2/1/18.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import UIKit

enum Setting: String {
    // Bool settings with SettingsViewController switches
    case debugMode
    case scaleWithPinchGesture
    case ambientLightEstimation
    case dragOnInfinitePlanes
    case showHitTestAPI
    case use3DOFTracking
    case use3DOFFallback
    case useOcclusionPlanes
    case detectVerticalPlanes
    
    // Integer state used in virtual object picker
    case selectedObjectID
    
    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            Setting.ambientLightEstimation.rawValue: true,
            Setting.dragOnInfinitePlanes.rawValue: true,
            Setting.selectedObjectID.rawValue: -1,
            Setting.detectVerticalPlanes.rawValue: true
            ])
    }
}
extension UserDefaults {
    func bool(for setting: Setting) -> Bool {
        return bool(forKey: setting.rawValue)
    }
    func set(_ bool: Bool, for setting: Setting) {
        set(bool, forKey: setting.rawValue)
    }
    func integer(for setting: Setting) -> Int {
        return integer(forKey: setting.rawValue)
    }
    func set(_ integer: Int, for setting: Setting) {
        set(integer, forKey: setting.rawValue)
    }
}

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var debugModeSwitch: UISwitch!
    @IBOutlet weak var scaleWithPinchGestureSwitch: UISwitch!
    @IBOutlet weak var ambientLightEstimateSwitch: UISwitch!
    @IBOutlet weak var dragOnInfinitePlanesSwitch: UISwitch!
    @IBOutlet weak var showHitTestAPISwitch: UISwitch!
    @IBOutlet weak var use3DOFTrackingSwitch: UISwitch!
    @IBOutlet weak var useAuto3DOFFallbackSwitch: UISwitch!
    @IBOutlet weak var useOcclusionPlanesSwitch: UISwitch!
    @IBOutlet weak var verticalPlaneDetectionSwitch: UISwitch!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateSettings()
    }
    
    @IBAction func didChangeSetting(_ sender: UISwitch) {
        let defaults = UserDefaults.standard
        switch sender {
        case debugModeSwitch:
            defaults.set(sender.isOn, for: .debugMode)
        case scaleWithPinchGestureSwitch:
            defaults.set(sender.isOn, for: .scaleWithPinchGesture)
        case ambientLightEstimateSwitch:
            defaults.set(sender.isOn, for: .ambientLightEstimation)
        case dragOnInfinitePlanesSwitch:
            defaults.set(sender.isOn, for: .dragOnInfinitePlanes)
        case showHitTestAPISwitch:
            defaults.set(sender.isOn, for: .showHitTestAPI)
        case use3DOFTrackingSwitch:
            defaults.set(sender.isOn, for: .use3DOFTracking)
        case useAuto3DOFFallbackSwitch:
            defaults.set(sender.isOn, for: .use3DOFFallback)
        case useOcclusionPlanesSwitch:
            defaults.set(sender.isOn, for: .useOcclusionPlanes)
        case verticalPlaneDetectionSwitch:
            defaults.set(sender.isOn, for: .detectVerticalPlanes)
        default: break
        }
    }
    
    private func populateSettings() {
        let defaults = UserDefaults.standard
        
        debugModeSwitch.isOn = defaults.bool(for: Setting.debugMode)
        scaleWithPinchGestureSwitch.isOn = defaults.bool(for: .scaleWithPinchGesture)
        ambientLightEstimateSwitch.isOn = defaults.bool(for: .ambientLightEstimation)
        dragOnInfinitePlanesSwitch.isOn = defaults.bool(for: .dragOnInfinitePlanes)
        showHitTestAPISwitch.isOn = defaults.bool(for: .showHitTestAPI)
        use3DOFTrackingSwitch.isOn = defaults.bool(for: .use3DOFTracking)
        useAuto3DOFFallbackSwitch.isOn = defaults.bool(for: .use3DOFFallback)
        useOcclusionPlanesSwitch.isOn = defaults.bool(for: .useOcclusionPlanes)
        verticalPlaneDetectionSwitch.isOn = defaults.bool(for: .detectVerticalPlanes)
    }
}


//
//  SCNNode+Extensions.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 2/11/18.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import SceneKit
import Assimp

/**
 A scenekit SCNNode category which imitates the SCNAnimatable protocol.
 */
public extension SCNNode {
    
    // MARK: - SCNAnimatable Clone
    
    /// Adds the animation at the given node subtree to the corresponding node subtree
    /// in the scene.
    ///
    /// - Parameters:
    ///   - animNode: The node and it's subtree which has a CAAnimation.
    func addAnimation(from animNode: SCNNode,
                      forKey animKey: String,
                      with settings: AssetImporterAnimSettings,
                      hasEvents: inout Bool,
                      hasDelegate: inout Bool) {
        for nodeAnimKey in animNode.animationKeys {
            if let animation = animNode.animation(forKey: nodeAnimKey) {
                // CAMediaTiming
                animation.beginTime = settings.beginTime
                animation.timeOffset = settings.timeOffset
                animation.repeatCount = settings.repeatCount
                animation.repeatDuration = settings.repeatDuration
                if animation.duration == 0 {
                    animation.duration = settings.duration
                }
                animation.speed = settings.speed
                animation.autoreverses = settings.autoreverses
                animation.fillMode = settings.fillMode
                // Animation attributes
                animation.isRemovedOnCompletion = settings.isRemovedOnCompletion
                animation.timingFunction = settings.timingFunction
                // Controlling SceneKit Animation Timing
                animation.usesSceneTimeBase = settings.usesSceneTimeBase
                // Fading Between SceneKit Animations
                animation.fadeInDuration = settings.fadeInDuration
                animation.fadeOutDuration = settings.fadeOutDuration
                if hasEvents {
                    animation.animationEvents = settings.animationEvents
                    hasEvents = false
                }
                if hasDelegate {
                    animation.delegate = settings.delegate
                    hasDelegate = false
                }
                if let boneName = animNode.name,
                    let sceneBoneNode = childNode(withName: boneName,
                                                  recursively: true) {
                    let key: String = nodeAnimKey + ("-") + (animKey)
                    sceneBoneNode.addAnimation(animation,
                                               forKey: key)
                }
            }
        }
        for childNode in animNode.childNodes {
            self.addAnimation(from: childNode,
                              forKey: animKey,
                              with: settings,
                              hasEvents: &hasEvents,
                              hasDelegate: &hasDelegate)
        }
        
    }
    
    /// Adds a skeletal animation scene to the scene.
    ///
    /// - Parameters:
    ///   - animScene: The scene object representing the animation.
    func addAnimationScene(_ animScene: SCNScene,
                           forKey animKey: String,
                           with settings: AssetImporterAnimSettings) {
        let rootAnimNode = animScene.rootNode.findSkeletonRootNode()
        var hasEvents: Bool = settings.animationEvents.count > 0
        var hasDelegate: Bool = settings.delegate != nil
        if rootAnimNode.childNodes.count > 0 {
            self.addAnimation(from: rootAnimNode,
                              forKey: animKey,
                              with: settings,
                              hasEvents: &hasEvents,
                              hasDelegate: &hasDelegate)
        }
        else {
            // no root exists, so add animation data to all bones
            debugPrint(" no root: \(String(describing: rootAnimNode.parent)) \(String(describing: rootAnimNode.parent?.childNodes.count))")
            if let parent = rootAnimNode.parent {
                self.addAnimation(from: parent,
                                  forKey: animKey,
                                  with: settings,
                                  hasEvents: &hasEvents,
                                  hasDelegate: &hasDelegate)
            }
        }
    }
    
    func removeAnimation(at animNode: SCNNode,
                         forKey animKey: String,
                         fadeOutDuration: CGFloat,
                         withSuffixes suffixes: [String]) {
        if animNode.name != nil {
            let keyPrefix: String = "/node-" + (animNode.name ?? "")
            for suffix: String in suffixes {
                let key: String = keyPrefix + (suffix) + (animKey)
                animNode.removeAnimation(forKey: key)
            }
        }
        for child: SCNNode in animNode.childNodes {
            self.removeAnimation(at: child,
                                 forKey: animKey,
                                 fadeOutDuration: 0.0,
                                 withSuffixes: suffixes)
        }
    }
    
    /// Removes the animation attached to the object with the specified key.
    ///
    /// - Parameter animKey: A string identifying an attached animation to remove.
    func removeAnimationScene(forKey animKey: String) {
        let suffixes = [".transform.translation-", ".transform.quaternion-", ".transform.scale-"]
        self.removeAnimation(at: self,
                             forKey: animKey,
                             fadeOutDuration: 0.0,
                             withSuffixes: suffixes)
    }
    
    /// Removes the animation attached to the object with the specified key, smoothly
    /// transitioning out of the animation’s effect.
    ///
    /// - Parameters:
    ///   - animKey: A string identifying an attached animation to remove.
    ///   - fadeOutDuration: The duration for transitioning out of the animation’s
    /// effect before it is removed
    func removeAnimationScene(forKey animKey: String,
                              fadeOutDuration: CGFloat) {
        let suffixes = [".transform.translation-", ".transform.quaternion-", ".transform.scale-"]
        self.removeAnimation(at: self,
                             forKey: animKey,
                             fadeOutDuration: fadeOutDuration,
                             withSuffixes: suffixes)
    }
    
    func pauseAnimation(at animNode: SCNNode,
                        forKey animKey: String,
                        withSuffixes suffixes: [String]) {
        
        if animNode.name != nil {
            let keyPrefix: String = "/node-" + (animNode.name ?? "")
            for suffix: String in suffixes {
                let key: String = keyPrefix + (suffix) + (animKey)
                debugPrint(" pausing animation with key: \(key)")
                animNode.pauseAnimation(forKey: key)
            }
        }
        for child: SCNNode in animNode.childNodes {
            self.pauseAnimation(at: child,
                                forKey: animKey,
                                withSuffixes: suffixes)
        }
        
    }
    
    /// Pauses the animation attached to the object with the specified key.
    ///
    /// - Parameter animKey: A string identifying an attached animation.
    func pauseAnimationScene(forKey animKey: String) {
        let suffixes = [".transform.translation-", ".transform.quaternion-", ".transform.scale-"]
        self.pauseAnimation(at: self,
                            forKey: animKey,
                            withSuffixes: suffixes)
    }
    
    func resumeAnimation(at animNode: SCNNode,
                         forKey animKey: String,
                         withSuffixes suffixes: [String]) {
        
        if animNode.name != nil {
            let keyPrefix: String = "/node-" + (animNode.name ?? "")
            for suffix: String in suffixes {
                let key: String = keyPrefix + (suffix) + (animKey)
                debugPrint(" resuming animation with key: %@", key)
                animNode.resumeAnimation(forKey: key)
            }
        }
        for child: SCNNode in animNode.childNodes {
            self.resumeAnimation(at: child,
                                 forKey: animKey,
                                 withSuffixes: suffixes)
        }
        
    }
    
    /// Resumes a previously paused animation attached to the object with the specified
    /// key.
    ///
    /// - Parameter animKey: A string identifying an attached animation.
    func resumeAnimationScene(forKey animKey: String) {
        let suffixes = [".transform.translation-", ".transform.quaternion-", ".transform.scale-"]
        self.resumeAnimation(at: self,
                             forKey: animKey,
                             withSuffixes: suffixes)
    }
    
    func isAnimationForScenePaused(at animNode: SCNNode,
                                   forKey animKey: String,
                                   withSuffixes suffixes: [String]) -> Bool {
        var paused = false
        if animNode.name != nil {
            let keyPrefix: String = "/node-" + (animNode.name ?? "")
            for suffix: String in suffixes {
                let key: String = keyPrefix + (suffix) + (animKey)
                debugPrint(" resuming animation with key: %@", key)
                paused = animNode.isAnimationPaused(forKey: key)
            }
        }
        if paused {
            return paused
        }
        else {
            for child: SCNNode in animNode.childNodes {
                paused = self.isAnimationForScenePaused(at: child,
                                                        forKey: animKey,
                                                        withSuffixes: suffixes)
            }
        }
        return paused
    }
    
    /// Returns a Boolean value indicating whether the animation attached to the object
    /// with the specified key is paused.
    ///
    /// - Parameter animKey: A string identifying an attached animation.
    /// - Returns:  YES if the specified animation is paused. NO if the animation is
    /// running or no animation is attached to the object with that key.
    func isAnimationSceneForKeyPaused(_ animKey: String) -> Bool {
        let suffixes = [".transform.translation-", ".transform.quaternion-", ".transform.scale-"]
        return self.isAnimationForScenePaused(at: self,
                                              forKey: animKey,
                                              withSuffixes: suffixes)
    }
    
    // MARK: - Skeleton
    
    /// Finds the root node of the skeleton in the scene.
    ///
    /// - Returns: Retuns the root node of the skeleton in the scene.
    func findSkeletonRootNode() -> SCNNode {
        var rootAnimNode: SCNNode? = nil
        // find root of skeleton
        enumerateChildNodes({(child: SCNNode,
            stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            if child.animationKeys.count > 0 {
                debugPrint(" found anim: \(child.animationKeys) at node \(child)")
                rootAnimNode = child
                stop.pointee = true
            }
        })
        return rootAnimNode ?? SCNNode()
    }
    
    /// Finds the depth of the specified node from the scene's root node.
    ///
    /// - Returns: The depth from the scene's root node.
    func findDepth() -> Int {
        var depth: Int = 0
        var parentNode = self
        while (parentNode.parent != nil) {
            depth += 1
            parentNode = parentNode.parent!
        }
        return depth
    }
    
    /// Creates a scenekit camera to attach at the specified node.
    ///
    /// - Parameters:
    ///   - aiNode: The assimp node.
    ///   - aiScene: The assimp scene.
    /// - Returns: A new scenekit camera.
    func makeSCNCamera(from aiNode: aiNode,
                       in aiScene: aiScene) -> SCNCamera? {
        let nodeName = aiNode.mName.stringValue()
        let aiSceneCameras = aiScene.getCameras()
        for aiCamera in aiSceneCameras {
            let cameraNodeName = aiCamera.mName.stringValue()
            if (nodeName == cameraNodeName) {
                let camera = SCNCamera()
                if #available(macOS 10.13, iOS 11.0, *) {
                    camera.fieldOfView = CGFloat(aiCamera.mHorizontalFOV)
                }
                camera.zNear = Double(aiCamera.mClipPlaneNear)
                camera.zFar = Double(aiCamera.mClipPlaneFar)
                return camera
            }
        }
        return nil
    }
    
    /// Creates a scenekit light to attach at the specified node.
    ///
    /// - Parameters:
    ///   - aiNode: The assimp node.
    ///   - aiScene: The assimp scene.
    /// - Returns: A new scenekit light.
    func makeSCNLight(from aiNode: aiNode,
                      in aiScene: aiScene) -> SCNLight? {
        
        let aiNodeName = aiNode.mName.stringValue()
        let aiSceneLightsCount = Int(aiScene.mNumLights)
        let aiSceneLights = Array(UnsafeBufferPointer(start: aiScene.mLights,
                                                      count: aiSceneLightsCount)).map { $0!.pointee }
        for aiSceneLight in aiSceneLights {
            let aiLightNodeName = aiSceneLight.mName.stringValue()
            if aiNodeName == aiLightNodeName {
                debugPrint("Creating light for node \(aiNodeName)")
                debugPrint("ambient \(aiSceneLight.mColorAmbient.r), \(aiSceneLight.mColorAmbient.g), \(aiSceneLight.mColorAmbient.b)")
                debugPrint("diffuse \(aiSceneLight.mColorAmbient.r), \(aiSceneLight.mColorAmbient.g), \(aiSceneLight.mColorAmbient.b)")
                debugPrint("specular \(aiSceneLight.mColorAmbient.r), \(aiSceneLight.mColorAmbient.g), \(aiSceneLight.mColorAmbient.b)")
                debugPrint("inner angle \(aiSceneLight.mAngleInnerCone)")
                debugPrint("outer angle \(aiSceneLight.mAngleOuterCone)")
                debugPrint("att const \(aiSceneLight.mAttenuationConstant)")
                debugPrint("att linear \(aiSceneLight.mAttenuationLinear)")
                debugPrint("att quad \(aiSceneLight.mAttenuationQuadratic)")
                debugPrint("position \(aiSceneLight.mColorAmbient.r), \(aiSceneLight.mColorAmbient.g), \(aiSceneLight.mColorAmbient.b)")
                
                return SCNLight(from: aiSceneLight)
            }
        }
        return nil
    }
    
}


//
//  SCNNode+AssetImport.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 2/11/18.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import SceneKit

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
    public func addAnimation(from animNode: SCNNode,
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
    public func addAnimationScene(_ animScene: SCNScene,
                                  forKey animKey: String,
                                  with settings: AssetImporterAnimSettings) {
        let rootAnimNode = animScene.rootNode.findSkeletonRootNode()
        var hasEvents: Bool = settings.animationEvents.count > 0
        var hasDelegate: Bool = settings.delegate != nil
        if rootAnimNode.childNodes.count > 0 {
            addAnimation(from: rootAnimNode,
                         forKey: animKey,
                         with: settings,
                         hasEvents: &hasEvents,
                         hasDelegate: &hasDelegate)
        }
        else {
            // no root exists, so add animation data to all bones
            print(" no root: \(String(describing: rootAnimNode.parent)) \(String(describing: rootAnimNode.parent?.childNodes.count))")
            if let parent = rootAnimNode.parent {
                addAnimation(from: parent,
                             forKey: animKey,
                             with: settings,
                             hasEvents: &hasEvents,
                             hasDelegate: &hasDelegate)
            }
        }
    }
    
    public func removeAnimation(at animNode: SCNNode,
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
            removeAnimation(at: child,
                            forKey: animKey,
                            fadeOutDuration: 0.0,
                            withSuffixes: suffixes)
        }
    }
    
    /// Removes the animation attached to the object with the specified key.
    ///
    /// - Parameter animKey: A string identifying an attached animation to remove.
    public func removeAnimationScene(forKey animKey: String) {
        let suffixes = [".transform.translation-", ".transform.quaternion-", ".transform.scale-"]
        removeAnimation(at: self,
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
    public func removeAnimationScene(forKey animKey: String,
                                     fadeOutDuration: CGFloat) {
        let suffixes = [".transform.translation-", ".transform.quaternion-", ".transform.scale-"]
        removeAnimation(at: self,
                        forKey: animKey,
                        fadeOutDuration: fadeOutDuration,
                        withSuffixes: suffixes)
    }

    public func pauseAnimation(at animNode: SCNNode,
                               forKey animKey: String,
                               withSuffixes suffixes: [String]) {
        
        if animNode.name != nil {
            let keyPrefix: String = "/node-" + (animNode.name ?? "")
            for suffix: String in suffixes {
                let key: String = keyPrefix + (suffix) + (animKey)
                print(" pausing animation with key: \(key)")
                animNode.pauseAnimation(forKey: key)
            }
        }
        for child: SCNNode in animNode.childNodes {
            pauseAnimation(at: child,
                           forKey: animKey,
                           withSuffixes: suffixes)
        }
        
    }
    
    /// Pauses the animation attached to the object with the specified key.
    ///
    /// - Parameter animKey: A string identifying an attached animation.
    public func pauseAnimationScene(forKey animKey: String) {
        let suffixes = [".transform.translation-", ".transform.quaternion-", ".transform.scale-"]
        pauseAnimation(at: self,
                       forKey: animKey,
                       withSuffixes: suffixes)
    }
    
    public func resumeAnimation(at animNode: SCNNode,
                                forKey animKey: String,
                                withSuffixes suffixes: [String]) {
        
        if animNode.name != nil {
            let keyPrefix: String = "/node-" + (animNode.name ?? "")
            for suffix: String in suffixes {
                let key: String = keyPrefix + (suffix) + (animKey)
                print(" resuming animation with key: %@", key)
                animNode.resumeAnimation(forKey: key)
            }
        }
        for child: SCNNode in animNode.childNodes {
            resumeAnimation(at: child,
                            forKey: animKey,
                            withSuffixes: suffixes)
        }
        
    }
    
    /// Resumes a previously paused animation attached to the object with the specified
    /// key.
    ///
    /// - Parameter animKey: A string identifying an attached animation.
    public func resumeAnimationScene(forKey animKey: String) {
        let suffixes = [".transform.translation-", ".transform.quaternion-", ".transform.scale-"]
        resumeAnimation(at: self,
                        forKey: animKey,
                        withSuffixes: suffixes)
    }
    
    public func isAnimationForScenePaused(at animNode: SCNNode,
                                          forKey animKey: String,
                                          withSuffixes suffixes: [String]) -> Bool {
        var paused = false
        if animNode.name != nil {
            let keyPrefix: String = "/node-" + (animNode.name ?? "")
            for suffix: String in suffixes {
                let key: String = keyPrefix + (suffix) + (animKey)
                print(" resuming animation with key: %@", key)
                paused = animNode.isAnimationPaused(forKey: key)
            }
        }
        if paused {
            return paused
        }
        else {
            for child: SCNNode in animNode.childNodes {
                paused = isAnimationForScenePaused(at: child,
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
    public func isAnimationSceneForKeyPaused(_ animKey: String) -> Bool {
        let suffixes = [".transform.translation-", ".transform.quaternion-", ".transform.scale-"]
        return isAnimationForScenePaused(at: self,
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
                print(" found anim: \(child.animationKeys) at node \(child)")
                rootAnimNode = child
                stop.pointee = true
            }
        })
        return rootAnimNode ?? SCNNode()
    }
}


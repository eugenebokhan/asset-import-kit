//
//  SCNAssetImporterAnimSettings.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 2/11/18.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import SceneKit
import Assimp

/**
 SCNAssimpAnimSettings provides support for CAMediaTiming protocol, animation
 attributes and animating scenekit content.
 */
public struct AssetImporterAnimSettings {
    
    // MARK: - CAMediaTiming
    
    /**
     @name CAMediaTiming
     */
    /**
     Specifies the begin time of the receiver in relation to its parent object, if
     applicable.
     */
    public var beginTime: CFTimeInterval = 0
    
    /**
     Specifies an additional time offset in active local time.
     */
    public var timeOffset: CFTimeInterval = 0
    
    /**
     Determines the number of times the animation will repeat.
     */
    public var repeatCount: Float = 0.0
    
    /**
     Determines how many seconds the animation will repeat for.
     */
    public var repeatDuration: CFTimeInterval = 0
    
    /**
     Specifies the basic duration of the animation, in seconds.
     */
    public var duration: CFTimeInterval = 0
    
    /**
     Specifies how time is mapped to receiver’s time space from the parent time
     space.
     */
    public var speed: Float = 1.0
    
    /**
     Determines if the receiver plays in the reverse upon completion.
     */
    public var autoreverses: Bool = false
    
    /**
     Determines if the receiver’s presentation is frozen or removed once its active
     duration has completed.
     */
    public var fillMode: CAMediaTimingFillMode = .removed
    
    // MARK: - Animation attributes
    
    /**
     @name Animation attributes
     */
    /**
     Determines if the animation is removed from the target layer’s animations upon
     completion.
     */
    public var isRemovedOnCompletion: Bool = false
    
    /**
     An optional timing function defining the pacing of the animation.
     */
    public var timingFunction: CAMediaTimingFunction? = nil
    
    // MARK: - Getting and setting the delegate
    /**
     @name Getting and setting the delegate
     */
    /**
     Specifies the receiver’s delegate object.
     */
    public weak var delegate: CAAnimationDelegate?
    
    // MARK: - Controlling SceneKit Animation Timing
    
    /**
     Controlling SceneKit Animation Timing
     */
    /**
     For animations attached to SceneKit objects, a Boolean value that determines
     whether the animation is evaluated using the scene time or the system time.
     */
    public var usesSceneTimeBase: Bool = false
    
    // MARK: - Fading Between SceneKit Animations
    
    /**
     Fading Between SceneKit Animations
     */
    /**
     For animations attached to SceneKit objects, the duration for transitioning
     into the animation’s effect as it begins.
     */
    public var fadeInDuration: CGFloat = 0.0
    
    /**
     For animations attached to SceneKit objects, the duration for transitioning out
     of the animation’s effect as it ends.
     */
    public var fadeOutDuration: CGFloat = 0.0
    
    // MARK: - Attaching SceneKit Animation Events
    
    /**
     Attaching SceneKit Animation Events
     */
    /**
     For animations attached to SceneKit objects, a list of events attached to an
     animation.
     */
    public var animationEvents = [SCNAnimationEvent]()
    
    /**
     Makes an animation settings object with the default values.
     
     @return A settings object with the default values.
     */
    
    public init() {}
}


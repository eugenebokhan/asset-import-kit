//
//  BouncyButton.swift
//  3DViewer
//
//  Created by Eugene Bokhan on 1/9/18.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//


import Foundation
import UIKit

/**
 A simple button  with animated transitions.
 */
@IBDesignable final public class BouncyButton: UIButton {
    
    public enum PresentationType {
        case right
        case left
        case up
        case down
        case custom(degrees: CGFloat, radius: CGFloat)
    }
    
    /**
     Boolean indicates whether the button can bounce when is touched.
     
     By default the value is set to true.
     */
    public var bounceButtonOnTouch: Bool = true
    
    /**
     CGoint sets the initial and translated positions. Used for show and hide methods.
     
     By default the value is set to (0, 0)
     */
    public var initialPosition = CGPoint()
    public var translatedPosition = CGPoint()
    
    public var presentationType: PresentationType? {
        didSet { setupPositions() }
    }
    
    
    
    required public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        setup()
    }
    
    /**
     Initializes and returns a newly allocated view object with the specified frame rectangle.
     
     - parameter frame: The frame rectangle for the view, measured in points. The origin of the frame is relative to the superview in which you plan to add it. This method uses the frame rectangle to set the center and bounds properties accordingly.
     - returns: An initialized view object or nil if the object couldn't be created.
     */
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    public override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle("", for: state)
    }
    
    func setup() {
        setTitle("", for: .normal)
        
        clipsToBounds = true
        
        addTarget(self, action: #selector(highlightAction), for: .touchDown)
        addTarget(self, action: #selector(highlightAction), for: .touchDragEnter)
        addTarget(self, action: #selector(unhighlightAction), for: .touchDragExit)
        addTarget(self, action: #selector(unhighlightAction), for: .touchUpInside)
        addTarget(self, action: #selector(unhighlightAction), for: .touchCancel)
        
    }
    
    private func setupPositions() {
        
        switch self.presentationType {
        case .down?:
            self.initialPosition = CGPoint(x: self.bounds.origin.x, y: -self.bounds.size.height)
            self.translatedPosition = self.bounds.origin
        case .up?:
            self.initialPosition = CGPoint(x: self.bounds.origin.x, y: (self.superview?.bounds.size.height)!)
            self.translatedPosition = self.bounds.origin
        case .left?:
            self.initialPosition = CGPoint(x: -self.bounds.size.width, y: self.bounds.origin.y)
            self.translatedPosition = self.bounds.origin
        case .right?:
            self.initialPosition = CGPoint(x: (self.superview?.bounds.size.width)!, y: self.bounds.origin.y)
            self.translatedPosition = self.bounds.origin
        case .custom(let degrees, let radius)?:
            let x = self.bounds.width * radius * sin(degreesToRadians(degrees: degrees))
            let y = self.bounds.width * radius * cos(degreesToRadians(degrees: degrees))
            self.initialPosition = self.bounds.origin
            self.translatedPosition = CGPoint(x: x, y: y)
        case .none:
            break
        }
    }
    
    // Show & hide methods
    
    func show() {
        
        // Present button with animation
        let translationAnimation = animationWithKeyPath("transform.translation", damping: 20, stiffness: 125, duration: 0.8)
        translationAnimation.isRemovedOnCompletion = false
        translationAnimation.fromValue = self.initialPosition
        translationAnimation.toValue = self.translatedPosition
        self.layer.add(translationAnimation, forKey: "translation")
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.isRemovedOnCompletion = false
        opacityAnimation.fromValue = 0.7
        opacityAnimation.toValue = 1
        self.layer.add(opacityAnimation, forKey: "opacity")
        
        // Enable button and make it visible
        switch self.presentationType {
        case .some(.right):
            self.isEnabled = true
            self.isHidden = false
        case .some(.left):
            self.isEnabled = true
            self.isHidden = false
        case .some(.up):
            self.isEnabled = true
            self.isHidden = false
        case .some(.down):
            self.isEnabled = true
            self.isHidden = false
        case .custom( _, _)?:
            self.isHidden = false
        case .none:
            self.isEnabled = true
            self.isHidden = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            switch self.presentationType {
            case .some(.right):
                self.layer.setAffineTransform(CGAffineTransform.identity)
            case .some(.left):
                self.layer.setAffineTransform(CGAffineTransform.identity)
            case .some(.up):
                self.layer.setAffineTransform(CGAffineTransform.identity)
            case .some(.down):
                self.layer.setAffineTransform(CGAffineTransform.identity)
            case .custom(let degrees, let radius)?:
                let x = self.bounds.width * radius * sin(degreesToRadians(degrees: degrees))
                let y = self.bounds.width * radius * cos(degreesToRadians(degrees: degrees))
                self.layer.setAffineTransform(CGAffineTransform(translationX: x, y: y))
            case .none:
                break
            }
        }
    }
    
    func hide() {
        
        let translationAnimation = animationWithKeyPath("transform.translation", damping: 20, stiffness: 10, duration: 0.8)
        translationAnimation.isRemovedOnCompletion = false
        translationAnimation.fromValue = self.translatedPosition
        translationAnimation.toValue = self.initialPosition
        self.layer.add(translationAnimation, forKey: "translation")
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.isRemovedOnCompletion = false
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0.7
        self.layer.add(opacityAnimation, forKey: "opacity")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Disable button and make it invisible
            self.isEnabled = false
            self.isHidden = true
            self.isSelected = false
            
            self.layer.setAffineTransform(CGAffineTransform.identity)
        }
        
    }
    
    func shake() {
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        self.layer.add(animation, forKey: "position")
        
    }
    
    // MARK: - Action Methods
    
    @objc func highlightAction() {
        
        if bounceButtonOnTouch {
            let anim = animationWithKeyPath("transform.scale", damping: 20, stiffness: 1000)
            anim.isRemovedOnCompletion = false
            anim.toValue = 1.05
            
            layer.add(anim, forKey: "scaleup")
        }
        
    }
    
    @objc func unhighlightAction() {
        
        let anim = animationWithKeyPath("transform.scale", damping: 100, initialVelocity: 20, stiffness: 1000)
        anim.isRemovedOnCompletion = false
        anim.toValue = 1
        
        layer.add(anim, forKey: "scaledown")
        
    }
    
}

//
//  ScenePreviewViewContoller.swift
//  3DViewer
//
//  Created by Eugene Bokhan on 9/14/17.
//  Copyright © 2017 Eugene Bokhan. All rights reserved.
//

import UIKit
import ModelIO
import SceneKit
import SceneKit.ModelIO
import AssetImportKit

class ScenePreviewViewContoller: UIViewController, CAAnimationDelegate {
    
    // MARK: - UI Elements
    
    var sceneView = SCNView()
    
    // MARK: - Properties
    
    var scene = SCNScene()
    var modelContainerNode: SCNNode = {
        let modelContainerNode = SCNNode()
        modelContainerNode.name = "Model Container Node"
        modelContainerNode.constraints = []
        return modelContainerNode
    }()
    
    var file: FBFile? {
        didSet {
            self.title = file?.displayName
        }
    }
    var sceneDidLoad: Bool = false
    
    // MARK: -  View lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up the SceneView
        setupSceneView()
        setupButtons()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        sceneView.frame = self.view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !sceneDidLoad {
            MBProgressHUD.showAdded(to: self.sceneView, animated: true)
            DispatchQueue.main.async {
                self.loadScene()
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.sceneView, animated: true)
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        unloadScene()
    }
    
    // MARK: - Setup
    
    func setupSceneView() {
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.scene = scene
        sceneView.backgroundColor = #colorLiteral(red: 0.3490196078, green: 0.3490196078, blue: 0.3490196078, alpha: 1)
        sceneView.showsStatistics = true
        self.view.addSubview(sceneView)
    }
    
    func setupButtons() {
        // Share button
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(ScenePreviewViewContoller.shareFile(_:)))
        self.navigationItem.rightBarButtonItem = shareButton
    }
    
    // MARK: - Share
    
    @objc func shareFile(_ sender: UIBarButtonItem) {
        guard let file = file else {
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [file.filePath], applicationActivities: nil)
        
        if UIDevice.current.userInterfaceIdiom == .pad &&
            activityViewController.responds(to: #selector(getter: popoverPresentationController)) {
            activityViewController.popoverPresentationController?.barButtonItem = sender
        }
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - Load model to scene
    
    public func loadScene() {
        
        guard let file = file else {
            return
        }
        
        let filePath = file.filePath.path
        
        DispatchQueue.main.async {
            
            if (filePath as NSString).pathExtension == "scn" {
                do {
                    let scnScene = try SCNScene(url: URL(fileURLWithPath: filePath), options: nil)
                    for childNode in (scnScene.rootNode.childNodes) {
                        self.modelContainerNode.addChildNode(childNode)
                    }
                } catch let error {
                    print(error)
                }
                
            } else {
                
                do {
                    let assimpScene = try SCNScene.assimpScene(filePath: filePath,
                                                               postProcessSteps: [.defaultQuality])
                    let modelScene = assimpScene.modelScene
                    for childNode in modelScene.rootNode.childNodes {
                        self.modelContainerNode.addChildNode(childNode)
                    }
                    
                    self.sceneView.scene?.rootNode.addChildNode(self.modelContainerNode)
                    
                    let animationKeys = assimpScene.animationKeys()
                    // If multiple animations exist, load the first animation
                    if let numberOfAnimationKeys = animationKeys?.count {
                        if numberOfAnimationKeys > 0 {
                            var settings = AssetImporterAnimSettings()
                            settings.repeatCount = 5
                            
                            let key = animationKeys![0] as! String
                            let eventBlock: SCNAnimationEventBlock = { animation, animatedObject, playingBackwards in
                                print("Animation Event triggered")
                                return
                            }
                            let animEvent = SCNAnimationEvent(keyTime: 0.1, block: eventBlock)
                            let animEvents: [SCNAnimationEvent]  = [animEvent]
                            settings.animationEvents = animEvents
                            settings.delegate = self
                            
                            if let animation = assimpScene.animationScenes.value(forKey: key) as? SCNScene {
                                self.sceneView.scene?.rootNode.addAnimationScene(animation, forKey: key, with: settings)
                            }
                            
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
        sceneView.scene?.rootNode.addChildNode(self.modelContainerNode)
        sceneDidLoad = true
        
    }
    
    // MARK: - Dismiss SceneView
    
    func unloadScene() {
        for node in self.scene.rootNode.childNodes {
            node.removeFromParentNode()
            node.removeAllAnimations()
        }
    }
}

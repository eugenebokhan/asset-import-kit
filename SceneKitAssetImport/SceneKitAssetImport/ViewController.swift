//
//  ViewController.swift
//  SceneKitAssetImport
//
//  Created by Eugene Bokhan on 2/12/18.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import Cocoa
import SceneKit
import SceneKit.ModelIO
import AssetImportKit

class ViewController: NSViewController, CAAnimationDelegate, SCNSceneExportDelegate {
    
    // MARK: - UI Elements
    
    @IBOutlet weak var sceneView: SCNView!
    
    // MARK: - UI Actions
    
    @IBAction func openAssetAction(_ sender: Any) {
        openAsset()
    }
    @IBAction func saveSceneAction(_ sender: Any) {
        exportScene()
    }
    
    // MARK: - Properties
    
    var modelContainerNode: SCNNode = {
        let modelContainerNode = SCNNode()
        modelContainerNode.name = "Model Container Node"
        modelContainerNode.constraints = []
        return modelContainerNode
    }()
    var sceneDidLoad: Bool = false
    var assetPath: String? {
        didSet {
            loadScene()
        }
    }
    
    // MARK: - LifeCyfle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupSceneView()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    // MARK: - Setup
    
    func setupSceneView() {
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2489546655)
    }
    
    // MARK: - Load model to scene
    
    public func loadScene() {
        
        guard let filePath = assetPath else {
            return
        }
        
        // Clean Scene
        unloadScene()
        sceneView.scene = SCNScene()
        
        if (filePath as NSString).pathExtension == "scn" {
            do {
                let scnScene = try SCNScene(url: URL(fileURLWithPath: filePath), options: nil)
                for childNode in (scnScene.rootNode.childNodes) {
                    self.modelContainerNode.addChildNode(childNode)
                }
            } catch let error {
                print(error)
            }
            
            sceneView.scene?.rootNode.addChildNode(modelContainerNode)
            
        } else {
            
            do {
                let assimpScene = try SCNScene.assimpScene(filePath: filePath,
                                                           postProcessSteps: [.defaultQuality])
                let modelScene = assimpScene.modelScene
                modelScene.rootNode.childNodes.forEach {
                    self.modelContainerNode.addChildNode($0)
                }
                
                sceneView.scene?.rootNode.addChildNode(modelContainerNode)
                
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
                            sceneView.scene?.rootNode.addAnimationScene(animation, forKey: key, with: settings)
                        }
                        
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        sceneDidLoad = true
    }
    
    func unloadScene() {
        for node in modelContainerNode.childNodes {
            node.removeFromParentNode()
            node.removeAllAnimations()
        }
        sceneView.scene = nil
    }
    
    // MARK: - File Browsing
    
    func openPanel() -> NSOpenPanel {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        return openPanel
    }
    
    func openAsset() {
        let dialog = NSOpenPanel();
        dialog.title = "Choose an Asset file";
        dialog.showsResizeIndicator = true;
        dialog.showsHiddenFiles = false;
        dialog.canChooseDirectories = true;
        dialog.canCreateDirectories = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes = SCNScene.allowedFileExtensions();
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                assetPath = path
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    func exportScene() {
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["scn"]
        savePanel.begin { (result) -> Void in
            if result == NSApplication.ModalResponse.OK {
                if let sceneFileURL = savePanel.url,
                    let scene = self.sceneView.scene {
                    let success = scene.write(to: sceneFileURL,
                                              options: nil,
                                              delegate: self) { (totalProgress, error, stop) in
                                                print("Progress \(totalProgress) Error: \(String(describing: error))")
                    }
                    print("Success: \(success)")
                }
            } else {
                NSSound.beep()
            }
        }
    }
    
}


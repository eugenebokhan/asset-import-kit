 //
 //  VirtualObject.swift
 //  3DViewer
 //
 //  Created by Eugene Bokhan on 2/1/18.
 //  Copyright © 2018 Eugene Bokhan. All rights reserved.
 //
 
 import Foundation
 import ARKit
 import ModelIO
 import SceneKit
 import SceneKit.ModelIO
 import AssetImportKit
 
 
 var VirtualObjectsFilePath: String {
    //1 - manager lets you examine contents of a files and folders in your app; creates a directory to where we are saving it
    let manager = FileManager.default
    //2 - this returns an array of urls from our documentDirectory and we take the first path
    let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
    print("this is the url path in the documentDirectory \(String(describing: url))")
    //3 - creates a new path component and creates a new file called "Data" which is where we will store our Data array.
    return (url!.appendingPathComponent("VirtualObjects").path)
 }
 
 @objc class VirtualObject: SCNNode {
    
    var modelName: String = ""
    var fileExtension: String = ""
    var thumbImage: UIImage!
    var title: String = ""
    var modelLoaded: Bool = false
    var file: FBFile?
    
    var viewController: ARViewController?
    
    override init() {
        super.init()
        self.name = "Virtual object root node"
    }
    
    init(from sceneFile: FBFile) {
        
        super.init()
        
        self.name = "Virtual object root node"
        
        self.file = sceneFile
        self.modelName = sceneFile.displayName
        self.fileExtension = sceneFile.fileExtension!
        self.thumbImage = getThumbImage(from: sceneFile)
        self.title = sceneFile.displayName
        
    }
    
    init(modelName: String, fileExtension: String, thumbImageFilename: String, title: String) {
        super.init()
        self.name = "Virtual object root node"
        self.modelName = modelName
        self.fileExtension = fileExtension
        self.thumbImage = UIImage(named: thumbImageFilename)
        self.title = title
    }
    
    // MARK: - Conform to NSCoding
    override func encode(with aCoder: NSCoder) {
        print("encodeWithCoder")
        
        aCoder.encode(file, forKey: "file")
        
    }
    
    // since we inherit from NSObject, we're not a final class -> therefore this initializer must be declared as 'required'
    // it also must be declared as a 'convenience' initializer, because we still have a designated initializer as well
    required convenience init?(coder aDecoder: NSCoder) {
        print("decodeWithCoder")
        
        guard let file = aDecoder.decodeObject(forKey: "file") as? FBFile
            else {
                return nil
        }
        
        self.init(from: file)
    }
    
    func loadModel() {
        
        guard let file = file else {
            return
        }
        
        if FileManager.default.fileExists(atPath: updateFilePath(for: file).filePath.path) {
            
            let wrapperNode = getNode(from: file)
            
            self.addChildNode(wrapperNode)
            
            for child in self.childNodes {
                child.geometry?.firstMaterial?.lightingModel = .physicallyBased
                child.movabilityHint = .movable
            }
            
            modelLoaded = true
            
        } else {
            
            self.unloadModel()
            
            for objectIndex in 0 ... VirtualObject.availableObjects.count - 1 {
                if VirtualObject.availableObjects[objectIndex].modelName == self.modelName {
                    VirtualObject.availableObjects.remove(at: objectIndex)
                }
            }
            
            let alertView = UIAlertView(title: "Model Error", message: "Model file not found", delegate: nil, cancelButtonTitle: "Okay")
            alertView.show()
            
        }
        
        
    }
    
    func unloadModel() {
        for child in self.childNodes {
            child.removeFromParentNode()
        }
        
        modelLoaded = false
    }
    
    func translateBasedOnScreenPos(_ pos: CGPoint, instantly: Bool, infinitePlane: Bool) {
        
        guard let controller = viewController else {
            return
        }
        
        let result = controller.worldPositionFromScreenPosition(pos, objectPos: self.position, infinitePlane: infinitePlane)
        
        controller.moveVirtualObjectToPosition(result.position, instantly, !result.hitAPlane)
    }
    
    func getNode(from sceneFile: FBFile) -> SCNNode {
        
        var node = SCNNode()
        
        let filePath = updateFilePath(for: sceneFile).filePath.path as NSString
        
        if filePath.pathExtension == "scn" {
            do {
                let scnScene = try SCNScene(url: URL(fileURLWithPath: filePath as String), options: nil)
                for childNode in (scnScene.rootNode.childNodes) {
                    node.addChildNode(childNode)
                }
            } catch let error {
                print(error)
            }
            
        } else {
            
            do {
                let assimpScene = try SCNScene.assimpScene(filePath: filePath as String,
                                                           postProcessSteps: [.defaultQuality])
                let modelScene = assimpScene.modelScene
                for childNode in modelScene.rootNode.childNodes {
                    node.addChildNode(childNode)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return node
        
    }
    
    func updateFilePath(for file: FBFile) -> FBFile {
        
        var oldFilePath = file.filePath.path as NSString
        
        var pathComponents: [String] = []
        
        while oldFilePath.lastPathComponent != "Documents" {
            let pathComponent = oldFilePath.lastPathComponent
            pathComponents.append(pathComponent)
            oldFilePath = oldFilePath.deletingLastPathComponent as NSString
        }
        
        var filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path
        
        for i in 0 ... pathComponents.count - 1 {
            filePath = filePath! + "/\(pathComponents.reversed()[i])"
        }
        
        let newFile = file
        newFile.filePath = URL(fileURLWithPath: filePath!)
        
        return newFile
    }
    
    func getThumbImage(from sceneFile: FBFile) -> UIImage {
        
        var resultImage = UIImage()
        
        let imagePath = ((updateFilePath(for: sceneFile).filePath.path as NSString).deletingPathExtension as NSString).appendingPathExtension("png")
        
        if FileManager.default.fileExists(atPath: imagePath!) {
            
            if let image = UIImage(contentsOfFile: imagePath!) {
                resultImage = image
            }
            
        } else {
            
            let sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: 240, height: 240))
            sceneView.scene = SCNScene()
            sceneView.scene?.rootNode.addChildNode(getNode(from: sceneFile))
            let image = sceneView.snapshot()
            let resizedImage = image.resizeImage(targetSize: CGSize(width: 48, height: 48)).maskRoundedImage(radius: 24)
            resultImage = resizedImage
            
            // Write image to documents directory
            if let data = resultImage.pngData() {
                try? data.write(to: URL(fileURLWithPath: imagePath!))
            }
            
        }
        
        return resultImage
    }
    
    
 }
 
 extension VirtualObject {
    
    static func isNodePartOfVirtualObject(_ node: SCNNode) -> Bool {
        if node.name == "Virtual object root node" {
            return true
        }
        
        if node.parent != nil {
            return isNodePartOfVirtualObject(node.parent!)
        }
        
        return false
    }
    
    static var availableObjects: [VirtualObject] = [] {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "Virtual objects didSet"), object: nil, userInfo: nil)
            
            if VirtualObject.availableObjects.count != 0 {
                // Write objects to coreData
                
                NSKeyedArchiver.archiveRootObject(availableObjects, toFile: VirtualObjectsFilePath)
                
                
            }
        }
    }
    
    static func readCoreData() {
        
        if let ourData = NSKeyedUnarchiver.unarchiveObject(withFile: VirtualObjectsFilePath) as? [VirtualObject] {
            VirtualObject.availableObjects = ourData
        }
        
    }
    
 }
 
 // MARK: - Protocols for Virtual Objects
 
 protocol ReactsToScale {
    func reactToScale()
 }
 
 extension SCNNode {
    
    func reactsToScale() -> ReactsToScale? {
        if let canReact = self as? ReactsToScale {
            return canReact
        }
        
        if parent != nil {
            return parent!.reactsToScale()
        }
        
        return nil
    }
 }
 
 extension UIImage {
    
    func maskRoundedImage(radius: CGFloat) -> UIImage {
        let imageView: UIImageView = UIImageView(image: self)
        let layer = imageView.layer
        layer.masksToBounds = true
        layer.cornerRadius = radius
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return roundedImage!
    }
    
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
 }

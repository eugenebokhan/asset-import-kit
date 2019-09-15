//
//  SCNAssetImporter.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 2/11/18.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import Foundation
import SceneKit
import SceneKit.ModelIO
import Assimp

/// An importer that imports the files with formats supported by Assimp and
/// converts the assimp scene graph into a scenekit scene graph.
public class AssetImporter {
    
    // MARK: - Bone data
    
    /// The array of bone names across all meshes in all nodes.
    var boneNames: [String] = []
    
    /// The array of unique bone names across all meshes in all nodes.
    var uniqueBoneNames: [String] = []
    
    /// The array of unique bone nodes across all meshes in all nodes.
    var uniqueBoneNodes: [SCNNode] = []
    
    /// The dictionary of bone inverse bind transforms, where key is the bone name.
    var boneTransforms: [String : SCNMatrix4] = [:]
    
    /// The array of unique bone transforms for all unique bone nodes.
    var uniqueBoneTransforms: [SCNMatrix4] = []
    
    /// The root node of the skeleton in the scene.
    var skeleton = SCNNode()
    
    // MARK: - Loading a scene
    
    /// Loads a scene from the specified file path.
    /// - Parameters:
    ///     - filePath: The path to the scene file to load.
    ///     - postProcessSteps: The flags for all possible post processing steps.
    /// - Throws: A new scene object, or scene loading error.
    public func importScene(filePath: String,
                            postProcessSteps: PostProcessSteps) throws -> AssetImporterScene {
        
        /// Start the import on the given file with some example postprocessing
        /// Usually - if speed is not the most important aspect for you - you'll t
        /// probably to request more postprocessing than we do in this example.
        guard let aiScenePointer = aiImportFile(filePath ,
                                                UInt32(postProcessSteps.rawValue))
        else {
            // The pointer has a renference to nil if the import failed.
            let errorString = tupleOfInt8sToString(aiGetErrorString().pointee)
            debugPrint(" Scene importing failed for filePath \(filePath)")
            debugPrint(" Scene importing failed with error \(String(describing: errorString))")
            throw NSError(domain: "AssimpImporter",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey : errorString]) as Error
        }
        /// Access the aiScene instance referenced by aiScenePointer.
        var aiScene = aiScenePointer.pointee
        /// Now we can access the file's contents.
        let scnScene = self.makeSCNScene(fromAssimpScene: aiScene,
                                         at: filePath)
        /// We're done. Release all resources associated with this import.
        aiReleaseImport(&aiScene)
        /// Retutrn result
        return scnScene
    }
    
    // MARK: - Make scenekit scene
    
    /// Make SceneKit scene
    ///
    /// Creates a SceneKit scene from the scene representing the file at a given path.
    ///
    /// - Parameters:
    ///     - aiScene: The assimp scene.
    ///     - path: The path to the scene file to load.
    /// - Returns: A new scene object.
    public func makeSCNScene(fromAssimpScene aiScene: aiScene,
                             at path: String) -> AssetImporterScene {
        debugPrint("Make an SCNScene")
        let assetImporterScene = AssetImporterScene()
        /*
         ---------------------------------------------------------------------
         Assign geometry, materials, lights and cameras to the node
         ---------------------------------------------------------------------
         */
        let imageCache = AssimpImageCache()
        let aiRootNode = aiScene.mRootNode.pointee
        let scnRootNode = makeSCNNode(fromAssimpNode: aiRootNode,
                                      in: aiScene,
                                      atPath: path,
                                      imageCache: imageCache)
        assetImporterScene.rootNode.addChildNode(scnRootNode)
        /*
         ---------------------------------------------------------------------
         Animations and skinning
         ---------------------------------------------------------------------
         */
        self.buildSkeletonDatabase(for: assetImporterScene)
        self.makeSkinner(for: aiRootNode,
                         in: aiScene,
                         scnScene: assetImporterScene)
        self.createAnimations(from: aiScene,
                              with: assetImporterScene,
                              atPath: path)
        /*
         ---------------------------------------------------------------------
         Make SCNScene for model and animations
         ---------------------------------------------------------------------
         */
        assetImporterScene.makeModelScene()
        assetImporterScene.makeAnimationScenes()
        
        return assetImporterScene
    }
    
    // MARK: - Make scenekit node
    
    /// Make a SceneKit node
    ///
    /// Creates a new SceneKit node from the assimp scene node.
    ///
    /// - Parameters:
    ///     - aiNode: The assimp scene node.
    ///     - aiScene: The assimp scene.
    ///     - path: The path to the scene file to load.
    /// - Returns: A new scene node.
    func makeSCNNode(fromAssimpNode aiNode: aiNode,
                     in aiScene: aiScene,
                     atPath path: String,
                     imageCache: AssimpImageCache) -> SCNNode {
        
        let node = SCNNode()
        /*
         ---------------------------------------------------------------------
         Get the node's name
         ---------------------------------------------------------------------
         */
        node.name = aiNode.mName.stringValue()
        debugPrint("Creating node \(String(describing: node.name!)) with \(aiNode.mNumMeshes) meshes")
        /*
         ---------------------------------------------------------------------
         Make SCNGeometry
         ---------------------------------------------------------------------
         */
        let vertexCount = aiNode.getNumberOfVertices(in: aiScene)
        debugPrint("vertexCount : \(vertexCount)")
        if vertexCount > 0 {
            if let nodeGeometry = self.makeSCNGeometry(from: aiNode,
                                                       in: aiScene,
                                                       atPath: path,
                                                       imageCache: imageCache) {
                node.geometry = nodeGeometry
            }
        }
        /*
         ---------------------------------------------------------------------
         Create Light
         ---------------------------------------------------------------------
         */
        node.light = node.makeSCNLight(from: aiNode,
                                       in: aiScene)
        /*
         ---------------------------------------------------------------------
         Create Camera
         ---------------------------------------------------------------------
         */
        node.camera = node.makeSCNCamera(from: aiNode,
                                         in: aiScene)
        /*
         ---------------------------------------------------------------------
         Get bone names & bone transforms
         ---------------------------------------------------------------------
         */
        self.boneNames.append(contentsOf: aiNode.getBoneNames(from: aiScene))
        aiNode.getBoneTransforms(in: aiScene).forEach { self.boneTransforms[$0.0] = $0.1 }
        /*
         ---------------------------------------------------------------------
         Transform
         ---------------------------------------------------------------------
         */
        let aiNodeMatrix  = aiNode.mTransformation
        
        debugPrint("aiNodeTransform: \(aiNodeMatrix)")
        
        let simdMatrix = simd_matrix(simd_float4(aiNodeMatrix.a1, aiNodeMatrix.b1, aiNodeMatrix.c1, aiNodeMatrix.d1),
                                     simd_float4(aiNodeMatrix.a2, aiNodeMatrix.b2, aiNodeMatrix.c2, aiNodeMatrix.d2),
                                     simd_float4(aiNodeMatrix.a3, aiNodeMatrix.b3, aiNodeMatrix.c3, aiNodeMatrix.d3),
                                     simd_float4(aiNodeMatrix.a4, aiNodeMatrix.b4, aiNodeMatrix.c4, aiNodeMatrix.d4))
        
        let scnMatrix = SCNMatrix4(simdMatrix)
        node.transform = scnMatrix
        
        debugPrint("Node \(String(describing: node.name!)) position is: \(node.position)")
        
        aiNode.getChildNodes().forEach {
            let scnChildNode = makeSCNNode(fromAssimpNode: $0,
                                           in: aiScene,
                                           atPath: path,
                                           imageCache: imageCache)
            node.addChildNode(scnChildNode)
        }
        return node
    }
    
    // MARK: - Make scenekit materials
    
    /// Creates an array of scenekit materials one for each mesh of the specified node.
    ///
    /// - Parameters:
    ///   - aiNode:  The assimp node.
    ///   - aiScene: The assimp scene.
    ///   - path: The path to the scene file to load.
    ///   - imageCache: The texture image cache.
    /// - Returns: An array of scenekit materials.
    func makeMaterials(for aiNode: aiNode,
                       in aiScene: aiScene,
                       atPath path: String,
                       imageCache: AssimpImageCache) -> [SCNMaterial] {
        var scnMaterials: [SCNMaterial] = []
        let nodeAIMaterials = aiNode.getMaterials(from: aiScene)
        for var aiMaterial in nodeAIMaterials {
            debugPrint("Material name is \(aiMaterial.name)")
            let scnMaterial = SCNMaterial()
            scnMaterial.name = aiMaterial.name
            scnMaterial.loadContentsProperties(from: &aiMaterial,
                                               aiScene: aiScene,
                                               path: path,
                                               imageCache: imageCache)
            scnMaterial.loadMultiplyProperty(from: &aiMaterial)
            if #available(macOS 10.12, iOS 9.0, *) {
                scnMaterial.loadBlendModeProperty(from: &aiMaterial)
            }
            scnMaterial.loadCullModeProperty(from: &aiMaterial)
            scnMaterial.loadShininessProperty(from: &aiMaterial)
            scnMaterial.loadLightingModelProperty(from: &aiMaterial)
            scnMaterials.append(scnMaterial)
        }
        return scnMaterials
    }
    
    /// Creates a scenekit geometry to attach at the specified node.
    ///
    /// - Parameters:
    ///   - aiNode: The assimp node.
    ///   - aiScene: The assimp scene.
    ///   - path: The total number of vertices in the meshes of the node.
    ///   - imageCache: The texture image cache.
    /// - Returns: A new geometry.
    func makeSCNGeometry(from aiNode: aiNode,
                         in aiScene: aiScene,
                         atPath path: String,
                         imageCache: AssimpImageCache) -> SCNGeometry? {
        // make SCNGeometry with sources, elements and materials
        let scnGeometrySources = aiNode.makeGeometrySources(from: aiScene)
        if scnGeometrySources.count > 0 {
            var scnGeometry = SCNGeometry()
            let scnGeometryElements = aiNode.makeGeometryElementsForNode(from: aiScene)
            scnGeometry = SCNGeometry(sources: scnGeometrySources,
                                      elements: scnGeometryElements)
            let scnMaterials = makeMaterials(for: aiNode,
                                             in: aiScene,
                                             atPath: path,
                                             imageCache: imageCache)
            scnGeometry.materials = scnMaterials
            return scnGeometry
        } else {
            return nil
        }
    }
    
    // MARK: - Make scenekit skinner
    
    /// Creates an array of bone transforms from a dictionary of bone transforms where
    /// bone name is the key.
    ///
    /// - Parameters:
    ///   - boneNames: The array of bone names.
    ///   - boneTransforms: The dictionary of bone transforms.
    /// - Returns: An array of bone transforms
    func getTransforms(for boneNames: [String],
                       from boneTransforms: [String : SCNMatrix4]) -> [SCNMatrix4] {
        var transforms: [SCNMatrix4] = []
        for boneName in boneNames {
            if let boneTransform = boneTransforms[boneName] {
                transforms.append(boneTransform)
            }
        }
        return transforms
    }
    
    /// Find the root node of the skeleton from the specified bone nodes.
    ///
    /// - Parameter boneNodes: The array of bone nodes.
    /// - Returns: The root node of the skeleton.
    func findSkeletonNode(in boneNodes: [SCNNode]) -> SCNNode {
        var resultNode = SCNNode()
        let nodeDepths = NSMutableDictionary()
        var minDepth = -1
        for boneNode in boneNodes {
            let depth = boneNode.findDepth()
            if let boneNodeName = boneNode.name {
                debugPrint("bone with depth is (min depth): \(boneNodeName) -> \(depth) ( \(minDepth) )")
            }
            if minDepth == -1 || (depth <= minDepth) {
                minDepth = depth
                let key = "\(minDepth)"
                var minDepthNodes: NSMutableArray?
                if let value = nodeDepths.value(forKey: key) as? NSMutableArray {
                    minDepthNodes = value
                }
                if minDepthNodes == nil {
                    minDepthNodes = NSMutableArray()
                    nodeDepths.setValue(minDepthNodes, forKey: key)
                }
                if minDepthNodes != nil {
                    minDepthNodes!.add(boneNode)
                }
            }
        }
        let minDepthKey = "\(minDepth)"
        if let minDepthNodes = nodeDepths.value(forKey: minDepthKey) as? NSArray {
            debugPrint("min depth nodes are: \(String(describing: minDepthNodes))")
            if let skeletonRootNode = minDepthNodes[0] as? SCNNode {
                if minDepthNodes.count > 1 {
                    if skeletonRootNode.parent != nil {
                        resultNode = skeletonRootNode.parent!
                    } else {
                        resultNode = skeletonRootNode
                    }
                } else {
                    resultNode = skeletonRootNode
                }
            }
        }
        return resultNode
    }
    
    /// Creates a scenekit geometry source defining the influence of each bone on the
    /// positions of vertices in the geometry
    ///
    /// - Parameters:
    ///   - aiNode: The assimp node.
    ///   - aiScene: The assimp scene.
    ///   - vertexCount: The number of vertices in the meshes of the node.
    ///   - maxWeights: The maximum number of weights influencing each vertex.
    /// - Returns: A new geometry source whose semantic property is boneWeights.
    func makeBoneWeightsGeometrySource(at aiNode: aiNode,
                                       in aiScene: aiScene,
                                       vertexCount: Int,
                                       maxWeights: Int) -> SCNGeometrySource {
        let nodeGeometryWeights = UnsafeMutablePointer<Float>.allocate(capacity: vertexCount * maxWeights)
        defer { nodeGeometryWeights.deallocate() }
        var weightCounter: Int = 0
        let aiNodeMeshes = aiNode.getMeshes(from: aiScene)
        for aiMesh in aiNodeMeshes {
            var meshWeights: [UInt32 : [Float]] = [:]
            let aiMeshBones = aiMesh.getBones()
            for aiBone in aiMeshBones {
                let aiBoneWeights = aiBone.getVertexWeights()
                for aiVertexWeight in aiBoneWeights {
                    let vertexID = aiVertexWeight.mVertexId
                    let weight = aiVertexWeight.mWeight
                    if meshWeights[vertexID] == nil {
                        var weights: [Float] = []
                        weights.append(weight)
                        meshWeights[vertexID] = weights
                    } else {
                        meshWeights[vertexID]!.append(weight)
                    }
                }
            }
            // Add weights to the weights array for the entire node geometry
            for j in 0 ..< aiMesh.mNumVertices {
                let vertex = j
                if let weights = meshWeights[vertex] {
                    let zeroWeights = maxWeights - weights.count
                    for weight in weights {
                        nodeGeometryWeights[weightCounter] = weight
                        weightCounter += 1
                    }
                    for _ in 0 ..< zeroWeights {
                        nodeGeometryWeights[weightCounter] = Float(0.0)
                        weightCounter += 1
                    }
                }
            }
        }
        debugPrint("weight counter \(weightCounter)")
        
        assert(weightCounter == vertexCount * maxWeights)
        
        let dataLength = vertexCount * maxWeights * MemoryLayout<Float>.size
        let data = NSData(bytes: nodeGeometryWeights, length: dataLength) as Data
        let bytesPerComponent = MemoryLayout<Float>.size
        let dataStride = maxWeights * bytesPerComponent
        let boneWeightsSource = SCNGeometrySource(data: data,
                                                  semantic: .boneWeights,
                                                  vectorCount: vertexCount,
                                                  usesFloatComponents: true,
                                                  componentsPerVector: maxWeights,
                                                  bytesPerComponent: bytesPerComponent,
                                                  dataOffset: 0,
                                                  dataStride: dataStride)
        
        return boneWeightsSource
    }
    
    /// Creates a scenekit geometry source defining the mapping from bone indices in
    /// skeleton data to the skinner’s bones array
    ///
    /// - Parameters:
    ///   - aiNode: The assimp node.
    ///   - aiScene: The assimp scene.
    ///   - vertexCount: The number of vertices in the meshes of the node.
    ///   - maxWeights: The maximum number of weights influencing each vertex.
    ///   - boneNames: The array of unique bone names.
    /// - Returns: A new geometry source whose semantic property is boneIndices.
    func makeBoneIndicesGeometrySource(at aiNode: aiNode,
                                       in aiScene: aiScene,
                                       vertexCount: Int,
                                       maxWeights: Int,
                                       boneNames: [String]) -> SCNGeometrySource {
        
        debugPrint("Making bone indices geometry source: \(boneNames)")
        
        let nodeGeometryBoneIndices = UnsafeMutablePointer<CShort>.allocate(capacity: vertexCount * maxWeights)
        defer { nodeGeometryBoneIndices.deallocate() }
        var indexCounter: Int = 0
        let aiNodeMeshes = aiNode.getMeshes(from: aiScene)
        for aiMesh in aiNodeMeshes {
            let meshBoneIndices = NSMutableDictionary()
            let aiMeshBones = aiMesh.getBones()
            for aiBone in aiMeshBones {
                for k in 0 ..< aiBone.mNumWeights {
                    let aiVertexWeight = aiBone.mWeights[Int(k)]
                    let vertex = aiVertexWeight.mVertexId
                    let boneName = aiBone.mName.stringValue()
                    if let boneIndex = boneNames.firstIndex(of: boneName) {
                        if meshBoneIndices.value(forKey: "\(vertex)") == nil {
                            let boneIndices = NSMutableArray()
                            boneIndices.add(boneIndex)
                            meshBoneIndices.setValue(boneIndices,
                                                     forKey: "\(vertex)")
                        } else {
                            if let boneIndices = meshBoneIndices.value(forKey: "\(vertex)") as? NSMutableArray {
                                boneIndices.add(boneIndex)
                            }
                        }
                    }
                }
            }
            // Add bone indices to the indices array for the entire node geometry
            for j in 0 ..< aiMesh.mNumVertices {
                let vertex = j
                if let boneIndices = meshBoneIndices.value(forKey: "\(vertex)") as? NSMutableArray {
                    let zeroIndices = maxWeights - boneIndices.count
                    for index in boneIndices {
                        if let boneIndex = index as? CShort {
                            nodeGeometryBoneIndices[indexCounter] = boneIndex
                            indexCounter += 1
                        }
                    }
                    for _ in 0 ..< zeroIndices {
                        nodeGeometryBoneIndices[indexCounter] = 0
                        indexCounter += 1
                    }
                }
            }
        }
        assert(indexCounter == vertexCount * maxWeights)
        
        let dataLength = vertexCount * maxWeights * MemoryLayout<CShort>.size
        let data = NSData(bytes: nodeGeometryBoneIndices, length: dataLength) as Data
        let bytesPerComponent = MemoryLayout<CShort>.size
        let dataStride = maxWeights * bytesPerComponent
        let boneIndicesSource = SCNGeometrySource(data: data,
                                                  semantic: .boneWeights,
                                                  vectorCount: vertexCount,
                                                  usesFloatComponents: true,
                                                  componentsPerVector: maxWeights,
                                                  bytesPerComponent: bytesPerComponent,
                                                  dataOffset: 0,
                                                  dataStride: dataStride)
        return boneIndicesSource
    }
    
    /// Builds a skeleton database of unique bone names and inverse bind bone
    // transforms.
    ///
    /// When the scenekit scene is created from the assimp scene, a list of all bone
    /// names and a dictionary of bone transforms where each key is the bone name,
    /// is generated when parsing each node of the assimp scene.
    /// - Parameter scene: The scenekit scene.
    func buildSkeletonDatabase(for scene: AssetImporterScene) {
        
        self.uniqueBoneNames = self.boneNames
        
        debugPrint("bone names \(self.uniqueBoneNames.count): \(self.uniqueBoneNames)")
        debugPrint("unique bone names \(self.uniqueBoneNames.count): \(self.uniqueBoneNames)")
        
        self.uniqueBoneNodes = scene.getBoneNodes(for: uniqueBoneNames)
        
        debugPrint("unique bone nodes \(self.uniqueBoneNodes.count): \(self.uniqueBoneNodes)")
        
        self.uniqueBoneTransforms = self.getTransforms(for: self.uniqueBoneNames,
                                                       from: self.boneTransforms)
        
        debugPrint("unique bone transforms \(self.uniqueBoneTransforms.count): \(self.uniqueBoneTransforms)")
        
        self.skeleton = self.findSkeletonNode(in: self.uniqueBoneNodes)
        scene.skeletonNode = self.skeleton
        
        debugPrint("skeleton bone is : \(self.skeleton)")
        
    }
    
    /// Creates a scenekit skinner for the specified node with visible geometry and
    /// skeleton information.
    ///
    /// - Parameters:
    ///   - aiNode: The assimp node.
    ///   - aiScene: The assimp scene.
    ///   - scene: The scenekit scene.
    func makeSkinner(for aiNode: aiNode,
                     in aiScene: aiScene,
                     scnScene scene: AssetImporterScene) {
        
        let nBones: Int = aiNode.getNumberOfBones(in: aiScene)
        let aiNodeName = aiNode.mName
        let nodeName = aiNodeName.stringValue()
        if nBones > 0 {
            
            let vertexCount = aiNode.getNumberOfVertices(in: aiScene)
            let maxWeights = aiNode.findMaximumWeights(in: aiScene)
            
            debugPrint("Making Skinner for node: \(nodeName) vertices: \(vertexCount) max-weights: \(maxWeights), nBones: \(nBones)")
            
            let boneWeights = self.makeBoneWeightsGeometrySource(at: aiNode,
                                                                 in: aiScene,
                                                                 vertexCount: vertexCount,
                                                                 maxWeights: maxWeights)
            let boneIndices = self.makeBoneIndicesGeometrySource(at: aiNode,
                                                                 in: aiScene,
                                                                 vertexCount: vertexCount,
                                                                 maxWeights: maxWeights,
                                                                 boneNames: self.uniqueBoneNames)
            
            if let node = scene.rootNode.childNode(withName: nodeName, recursively: true) {
                
                debugPrint(self.uniqueBoneNodes.count)
                debugPrint(self.uniqueBoneTransforms.count)
                let skinner = SCNSkinner(baseGeometry: node.geometry,
                                         bones: self.uniqueBoneNodes,
                                         boneInverseBindTransforms: self.uniqueBoneTransforms as [NSValue],
                                         boneWeights: boneWeights,
                                         boneIndices: boneIndices)
                skinner.skeleton = self.skeleton
                
                debugPrint(" assigned skinner \(skinner) skeleton: \(String(describing: skinner.skeleton))")
                
                node.skinner = skinner
                
            }
        }
        aiNode.getChildNodes().forEach {
            self.makeSkinner(for: $0,
                             in: aiScene,
                             scnScene: scene)
        }
    }
    
    // MARK: - Make scenekit animations
    
    /// Creates a dictionary of animations where each animation is a
    /// SCNAssimpAnimation, from each animation in the assimp scene.
    ///
    /// For each animation's channel which is a bone node, a CAKeyframeAnimation is
    /// created for each of position, orientation and scale. These animations are
    /// then stored in an SCNAssimpAnimation object, which holds the animation name and
    /// the keyframe animations.
    ///
    /// The animation name is generated by appending the file name with an animation
    /// index. The example of an animation name is walk-1 for the first animation in a
    /// file named walk.
    ///
    /// - Parameters:
    ///   - aiScene: The assimp scene.
    ///   - scene: The scenekit scene.
    ///   - path: The path to the scene file to load.
    func createAnimations(from aiScene: aiScene,
                          with scene: AssetImporterScene,
                          atPath path: String) {
        
        debugPrint("Number of animations in scene: \(aiScene.mNumAnimations)")
        for i in 0 ..< aiScene.mNumAnimations {
            debugPrint("Animation data for animation at index: \(i)")
            if let aiAnimationPointer = aiScene.mAnimations[Int(i)] {
                let aiAnimation = aiAnimationPointer.pointee
                let animIndex = "-" + "\(i + 1)"
                let animName = (((((path as NSString).lastPathComponent) as NSString).deletingPathExtension) as NSString).appending(animIndex)
                debugPrint("Generated animation name: \(animName)")
                let currentAnimation = NSMutableDictionary()
                debugPrint("This animation \(animName) has \(aiAnimation.mNumChannels) channels with duration \(aiAnimation.mDuration) ticks per sec: \(aiAnimation.mTicksPerSecond)")
                var duration: Double
                if aiAnimation.mTicksPerSecond != 0 {
                    duration = aiAnimation.mDuration / aiAnimation.mTicksPerSecond
                } else {
                    duration = aiAnimation.mDuration
                }
                for j in 0 ..< aiAnimation.mNumChannels {
                    if let aiNodeAnim: aiNodeAnim = aiAnimation.mChannels[Int(j)]?.pointee {
                        let aiNodeName = aiNodeAnim.mNodeName
                        let name = aiNodeName.stringValue()
                        debugPrint(" The channel \(name) has data for \(aiNodeAnim.mNumPositionKeys) position, \(aiNodeAnim.mNumRotationKeys) rotation, \(aiNodeAnim.mNumScalingKeys) scale keyframes")
                        // create a lookup for all animation keys
                        let channelKeys = NSMutableDictionary()
                        // create translation animation
                        let translationValues = NSMutableArray()
                        let translationTimes = NSMutableArray()
                        for k in 0 ..< aiNodeAnim.mNumPositionKeys {
                            let aiTranslationKey: aiVectorKey = aiNodeAnim.mPositionKeys[Int(k)]
                            let keyTime = aiTranslationKey.mTime
                            let aiTranslation = aiTranslationKey.mValue
                            translationTimes.add(Float(keyTime))
                            let pos = SCNVector3(aiTranslation.x,
                                                 aiTranslation.y,
                                                 aiTranslation.z)
                            translationValues.add(pos)
                        }
                        let translationKeyFrameAnim = CAKeyframeAnimation(keyPath: "position")
                        translationKeyFrameAnim.values = translationValues as? [Any]
                        translationKeyFrameAnim.keyTimes = translationTimes as? [NSNumber]
                        translationKeyFrameAnim.duration = duration
                        channelKeys.setValue(translationKeyFrameAnim, forKey: "position")
                        // create rotation animation
                        let rotationValues = NSMutableArray()
                        let rotationTimes = NSMutableArray()
                        for k in 0 ..< aiNodeAnim.mNumRotationKeys {
                            
                            let aiQuatKey = aiNodeAnim.mRotationKeys[Int(k)]
                            let keyTime = aiQuatKey.mTime
                            let aiQuaternion = aiQuatKey.mValue
                            rotationTimes.add(Float(keyTime))
                            let quat = SCNVector4(aiQuaternion.x,
                                                  aiQuaternion.y,
                                                  aiQuaternion.z,
                                                  aiQuaternion.w)
                            rotationValues.add(quat)
                        }
                        let rotationKeyFrameAnim = CAKeyframeAnimation(keyPath: "orientation")
                        rotationKeyFrameAnim.values = rotationValues as? [Any]
                        rotationKeyFrameAnim.keyTimes = rotationTimes as? [NSNumber]
                        rotationKeyFrameAnim.duration = duration
                        channelKeys.setValue(rotationKeyFrameAnim, forKey: "orientation")
                        // create scale animation
                        let scaleValues = NSMutableArray()
                        let scaleTimes = NSMutableArray()
                        for k in 0 ..< aiNodeAnim.mNumScalingKeys {
                            let aiScaleKey = aiNodeAnim.mScalingKeys[Int(k)]
                            let keyTime = aiScaleKey.mTime
                            let aiScale = aiScaleKey.mValue
                            scaleTimes.add(Float(keyTime))
                            let scale = SCNVector3(aiScale.x,
                                                   aiScale.y,
                                                   aiScale.z)
                            scaleValues.add(scale)
                        }
                        let scaleKeyFrameAnim = CAKeyframeAnimation(keyPath: "scale")
                        scaleKeyFrameAnim.values = scaleValues as? [Any]
                        scaleKeyFrameAnim.keyTimes = scaleTimes as? [NSNumber]
                        scaleKeyFrameAnim.duration = duration
                        channelKeys.setValue(scaleKeyFrameAnim, forKey: "scale")
                        currentAnimation.setValue(channelKeys, forKey: name)
                    }
                }
                let animation = AssetImporterAnimation(key: animName, frameAnims: currentAnimation)
                scene.animations.setValue(animation, forKey: animName)
            }
        }
    }
}


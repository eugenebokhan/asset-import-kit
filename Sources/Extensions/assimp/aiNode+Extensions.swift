//
//  aiNode+Extensions.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 01/12/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import SceneKit
import Assimp

extension aiNode {
    
    /// Creates an array of scenekit geometry element obejcts describing how to
    /// connect the geometry's vertices of the specified node.
    ///
    /// - Parameter aiScene: The assimp node.
    /// - Returns: An array of geometry elements.
    func makeGeometryElementsForNode(from aiScene: aiScene) -> [SCNGeometryElement] {
        
        var scnGeometryElements: [SCNGeometryElement] = []
        var indexOffset: Int = 0
        let aiMeshes = getMeshes(from: aiScene)
        for aiMesh in aiMeshes {
            let numberOfFaces = Int(aiMesh.mNumFaces)
            if let indices = aiMesh.makeIndicesGeometryElement(with: indexOffset,
                                                               numberOfFaces: numberOfFaces) {
                scnGeometryElements.append(indices)
            }
            indexOffset += Int(aiMesh.mNumVertices)
        }
        return scnGeometryElements
    }
    
    /// Creates a scenekit geometry source from the vertices of the specified node.
    ///
    /// - Parameter aiScene: The assimp scene.
    /// - Returns: A new geometry source whose semantic property is vertex.
    func makeVertexGeometrySource(from aiScene: aiScene) -> SCNGeometrySource {
        let numberOfVertices = getNumberOfVertices(in: aiScene)
        let scnVertices = UnsafeMutablePointer<Float32>.allocate(capacity: numberOfVertices * 3)
        defer { scnVertices.deallocate() }
        var verticesCounter: Int = 0
        let aiMeshes = getMeshes(from: aiScene)
        for aiMesh in aiMeshes {
            if let aiMeshVertices = aiMesh.mVertices {
                debugPrint("Getting vertices")
                for vertexIndex in 0 ..< Int(aiMesh.mNumVertices) {
                    let aiVector3D = aiMeshVertices[vertexIndex]
                    scnVertices[verticesCounter] = aiVector3D.x
                    verticesCounter += 1
                    scnVertices[verticesCounter] = aiVector3D.y
                    verticesCounter += 1
                    scnVertices[verticesCounter] = aiVector3D.z
                    verticesCounter += 1
                }
            }
        }

        let dataLength = numberOfVertices * 3 * MemoryLayout<Float32>.size
        let data = NSData(bytes: scnVertices, length: dataLength) as Data
        let bytesPerComponent = MemoryLayout<Float32>.size
        let dataStride = 3 * bytesPerComponent
        let vertexSource = SCNGeometrySource(data: data,
                                             semantic: .vertex,
                                             vectorCount: numberOfVertices,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: bytesPerComponent,
                                             dataOffset: 0,
                                             dataStride: dataStride)
        return vertexSource
    }
    
    /// Creates a scenekit geometry source from the texture coordinates of the
    /// makeTextureGeometrySourceForNodespecified node.
    ///
    /// - Parameter aiScene: The assimp scene.
    /// - Returns: A new geometry source whose semantic property is texcoord.
    func makeTextureGeometrySource(from aiScene: aiScene) -> SCNGeometrySource {
        let numberOfVertices = getNumberOfVertices(in: aiScene)
        let scnTextures = UnsafeMutablePointer<Float32>.allocate(capacity: numberOfVertices * 3)
        defer { scnTextures.deallocate() }
        var verticesCounter: Int = 0
        let aiMeshes = getMeshes(from: aiScene)
        for aiMesh in aiMeshes {
            if let textureCoordinates = aiMesh.mTextureCoords.0 {
                debugPrint("Getting texture coordinates")
                for vertexIndex in 0 ..< Int(aiMesh.mNumVertices) {
                    let x = textureCoordinates[vertexIndex].x
                    let y = textureCoordinates[vertexIndex].y
                    scnTextures[verticesCounter] = x
                    verticesCounter += 1
                    scnTextures[verticesCounter] = y
                    verticesCounter += 1
                }
            }
        }
        
        let dataLength = numberOfVertices * 2 * MemoryLayout<Float32>.size
        let data = NSData(bytes: scnTextures, length: dataLength) as Data
        let bytesPerComponent = MemoryLayout<Float32>.size
        let dataStride = 2 * bytesPerComponent
        let textureSource = SCNGeometrySource(data: data,
                                              semantic: .texcoord,
                                              vectorCount: numberOfVertices,
                                              usesFloatComponents: true,
                                              componentsPerVector: 2,
                                              bytesPerComponent: bytesPerComponent,
                                              dataOffset: 0,
                                              dataStride: dataStride)
        return textureSource
    }
    
    @available(OSX 10.12, iOS 10.0, *)
    /// Creates a scenekit geometry source from the tangents of the specified node.
    ///
    /// - Parameter aiScene: The assimp scene.
    /// - Returns: The assimp scene.
    func makeTangentGeometrySource(from aiScene: aiScene) -> SCNGeometrySource {
        let numberOfVertices = getNumberOfVertices(in: aiScene)
        let scnTangents = UnsafeMutablePointer<Float32>.allocate(capacity: numberOfVertices * 3)
        defer { scnTangents.deallocate() }
        var verticesCounter: Int = 0
        let aiMeshes = getMeshes(from: aiScene)
        for aiMesh in aiMeshes {
            if let aiMeshTangents = aiMesh.mTangents {
                debugPrint("Getting tangents")
                for vertexIndex in 0 ..< Int(aiMesh.mNumVertices) {
                    let aiVector3D = aiMeshTangents[vertexIndex]
                    scnTangents[verticesCounter] = aiVector3D.x
                    verticesCounter += 1
                    scnTangents[verticesCounter] = aiVector3D.y
                    verticesCounter += 1
                    scnTangents[verticesCounter] = aiVector3D.z
                    verticesCounter += 1
                }
            }
        }
        
        let dataLength = numberOfVertices * 3 * MemoryLayout<Float32>.size
        let data = NSData(bytes: scnTangents, length: dataLength) as Data
        let bytesPerComponent = MemoryLayout<Float32>.size
        let dataStride = 3 * bytesPerComponent
        let tangentSource = SCNGeometrySource(data: data,
                                              semantic: .tangent,
                                              vectorCount: numberOfVertices,
                                              usesFloatComponents: true,
                                              componentsPerVector: 3,
                                              bytesPerComponent: bytesPerComponent,
                                              dataOffset: 0,
                                              dataStride: dataStride)
        return tangentSource
    }
    
    /// Creates a scenekit geometry source from the normals of the specified node.
    ///
    /// - Parameter aiScene: The assimp scene.
    /// - Returns: A new geometry source whose semantic property is normal.
    func makeNormalGeometrySource(from aiScene: aiScene) -> SCNGeometrySource {
        let numberOfVertices = getNumberOfVertices(in: aiScene)
        let scnNormals = UnsafeMutablePointer<Float32>.allocate(capacity: numberOfVertices * 3)
        defer { scnNormals.deallocate() }
        var verticesCounter: Int = 0
        let aiMeshes = getMeshes(from: aiScene)
        for aiMesh in aiMeshes {
            if let aiMeshNormals = aiMesh.mNormals {
                debugPrint("Getting normals")
                for vertexIndex in 0 ..< Int(aiMesh.mNumVertices) {
                    let aiVector3D = aiMeshNormals[vertexIndex]
                    scnNormals[verticesCounter] = aiVector3D.x
                    verticesCounter += 1
                    scnNormals[verticesCounter] = aiVector3D.y
                    verticesCounter += 1
                    scnNormals[verticesCounter] = aiVector3D.z
                    verticesCounter += 1
                }
            }
        }
        
        let dataLength = numberOfVertices * 3 * MemoryLayout<Float32>.size
        let data = NSData(bytes: scnNormals, length: dataLength) as Data
        let bytesPerComponent = MemoryLayout<Float32>.size
        let dataStride = 3 * bytesPerComponent
        let normalSource = SCNGeometrySource(data: data,
                                             semantic: .normal,
                                             vectorCount: numberOfVertices,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: bytesPerComponent,
                                             dataOffset: 0,
                                             dataStride: dataStride)
        return normalSource
    }
    
    /// Creates an array of geometry sources for the specifed node describing
    /// the vertices in the geometry and their attributes.
    ///
    /// - Parameter aiScene: The assimp scene.
    /// - Returns: An array of geometry sources.
    func makeGeometrySources(from aiScene: aiScene) -> [SCNGeometrySource] {
        var scnGeometrySources: [SCNGeometrySource] = []
        scnGeometrySources.append(makeVertexGeometrySource(from: aiScene))
        scnGeometrySources.append(makeNormalGeometrySource(from: aiScene))
        scnGeometrySources.append(makeTextureGeometrySource(from: aiScene))
        if #available(macOS 10.12, iOS 10.0, *) {
            scnGeometrySources.append(makeTangentGeometrySource(from: aiScene))
        }
        if let colorGeometrySource = makeColorGeometrySource(from: aiScene) {
            scnGeometrySources.append(colorGeometrySource)
        }
        return scnGeometrySources
    }
    
    /// Creates a scenekit vertex color source from the vertex color information of
    /// the specified node.
    ///
    /// - Parameter aiScene: The assimp scene.
    /// - Returns: A new color source whose semantic property is vertex color.
    func makeColorGeometrySource(from aiScene: aiScene) -> SCNGeometrySource? {
        let numberOfVertices = getNumberOfVertices(in: aiScene)
        let scnColors = UnsafeMutablePointer<Float32>.allocate(capacity: numberOfVertices * 3)
        defer { scnColors.deallocate() }
        var colorsCounter: Int = 0
        let aiMeshes = getMeshes(from: aiScene)
        for aiMesh in aiMeshes {
            if let aiColors = aiMesh.mColors.0 {
                debugPrint("Getting colors")
                for vertexIndex in 0 ..< Int(aiMesh.mNumVertices) {
                    scnColors[colorsCounter] = aiColors[vertexIndex].r
                    colorsCounter += 1
                    scnColors[colorsCounter] = aiColors[vertexIndex].g
                    colorsCounter += 1
                    scnColors[colorsCounter] = aiColors[vertexIndex].b
                    colorsCounter += 1
                }
            } else {
                return nil
            }
        }
        
        let dataLength = numberOfVertices * 3 * MemoryLayout<Float32>.size
        let nsData = NSData(bytes: scnColors, length: dataLength)
        let data = nsData as Data
        let bytesPerComponent = MemoryLayout<Float32>.size
        let dataStride = 3 * bytesPerComponent
        let colorSource = SCNGeometrySource(data: data,
                                            semantic: .color,
                                            vectorCount: numberOfVertices,
                                            usesFloatComponents: true,
                                            componentsPerVector: 3,
                                            bytesPerComponent: bytesPerComponent,
                                            dataOffset: 0,
                                            dataStride: dataStride)
        return colorSource
    }
    
    /// Find the number of vertices, faces and indices of a geometry.
    ///
    /// Finds the total number of vertices in the meshes of the specified node.
    ///
    /// - Parameters:
    ///     -aiScene: The assimp scene.
    /// - Returns:
    ///     The number of vertices.
    func getNumberOfVertices(in aiScene: aiScene) -> Int {
        var nVertices: Int = 0
        let aiNodeMeshes = getMeshes(from: aiScene)
        for aiMesh in aiNodeMeshes {
            let numberOfVertices = Int(aiMesh.mNumVertices)
            nVertices += numberOfVertices
        }
        return nVertices
    }
    
    /// Finds the number of bones in the meshes of the specified node.
    /// - Parameters:
    ///     - aiNode: The assimp node.
    ///     - aiScene: The assimp scene.
    /// - Returns:
    ///     The number of bones.
    func getNumberOfBones(in aiScene: aiScene) -> Int {
        var numberOfBones: Int = 0
        let aiNodeMeshes = getMeshes(from: aiScene)
        for aiMesh in aiNodeMeshes {
            let aiMeshBonesCount = Int(aiMesh.mNumBones)
            numberOfBones += aiMeshBonesCount
        }
        return numberOfBones
    }
    
    func getMeshes(from aiScene: aiScene) -> [aiMesh] {
        let sceneMeshes = aiScene.getMeshes()
        let nodeMeshesCount = Int(mNumMeshes)
        var nodeMeshes = Array(repeating: aiMesh(),
                               count: nodeMeshesCount)
        for i in 0 ..< nodeMeshesCount {
            let meshIndex = Int(mMeshes[i])
            let aiMesh = sceneMeshes[meshIndex]
            nodeMeshes[i] = aiMesh
        }
        return nodeMeshes
    }
    
    func getMaterials(from scene: aiScene) -> [aiMaterial] {
        return getMeshes(from: scene).map { $0.getMaterial(from: scene) }
    }
    
    func getChildNodes() -> [aiNode] {
        let childNodesCount = Int(mNumChildren)
        let childNodes = Array(UnsafeBufferPointer(start: mChildren,
                                                    count: childNodesCount)).map { $0!.pointee }
        
        return childNodes
    }
    
    /// Finds the maximum number of weights that influence the vertices in the meshes
    /// of the specified node.
    ///
    /// - Parameter aiScene: The assimp scene.
    /// - Returns: The maximum influences or weights.
    func findMaximumWeights(in aiScene: aiScene) -> Int {
        var maxWeights: Int = 0
        let aiNodeMeshes = getMeshes(from: aiScene)
        for aiMesh in aiNodeMeshes {
            var aiMeshWeights: [UInt32 : Int] = [ : ]
            let aiMeshBones = aiMesh.getBones()
            for aiBone in aiMeshBones {
                let aiBoneVertexWeights = aiBone.getVertexWeights()
                for aiVertexWeight in aiBoneVertexWeights {
                    let vertexID = aiVertexWeight.mVertexId
                    aiMeshWeights[vertexID] = aiMeshWeights[vertexID] == nil ? 1 : aiMeshWeights[vertexID]! + 1
                }
            }
            // Find the vertex with most weights which is our max weights
            for i in 0 ..< aiMesh.mNumVertices {
                if let weightsCount = aiMeshWeights[i] {
                    if weightsCount > maxWeights {
                        maxWeights = weightsCount
                    }
                }
            }
        }
        return maxWeights
    }
    
    /// Creates an array of bone names in the meshes of the specified node.
    ///
    /// - Parameters:
    ///   - aiNode: The assimp node.
    ///   - aiScene: The assimp scene.
    /// - Returns: An array of bone names.
    func getBoneNames(from aiScene: aiScene) -> [String] {
        var boneNames: [String] = []
        let aiNodeMeshes = getMeshes(from: aiScene)
        for aiMesh in aiNodeMeshes {
            let aiMeshBones = aiMesh.getBones()
            for aiBone in aiMeshBones {
                let name = aiBone.mName.stringValue()
                boneNames.append(name)
            }
        }
        return boneNames
    }
    
    /// Creates a dictionary of bone transforms where bone name is the key, for the
    /// meshes of the specified node.
    ///
    /// - Parameter aiScene: The assimp scene.
    /// - Returns: A dictionary of bone transforms where bone name is the key.
    func getBoneTransforms(in aiScene: aiScene) -> [String : SCNMatrix4] {
        var boneTransforms: [String : SCNMatrix4] = [:]
        let aiSceneMeshes = aiScene.getMeshes()
        for aiMesh in aiSceneMeshes {
            let aiMeshBones = aiMesh.getBones()
            for aiBone in aiMeshBones {
                let key = aiBone.mName.stringValue()
                let aiNodeMatrix = aiBone.mOffsetMatrix
                let matrixColumns = [[aiNodeMatrix.a1, aiNodeMatrix.b1, aiNodeMatrix.c1, aiNodeMatrix.d1],
                                     [aiNodeMatrix.a2, aiNodeMatrix.b2, aiNodeMatrix.c2, aiNodeMatrix.d2],
                                     [aiNodeMatrix.a3, aiNodeMatrix.b3, aiNodeMatrix.c3, aiNodeMatrix.d3],
                                     [aiNodeMatrix.a4, aiNodeMatrix.b4, aiNodeMatrix.c4, aiNodeMatrix.d4]]
                                    .map { SIMD4<Float>($0.map { Float($0) }) }
                let scnMatrix = SCNMatrix4(float4x4(matrixColumns))
                boneTransforms[key] = scnMatrix
            }
        }
        return boneTransforms
    }
    
}

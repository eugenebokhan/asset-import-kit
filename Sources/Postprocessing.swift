//
//  Postprocessing.swift.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 27/11/2018.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import Assimp

public struct PostProcessSteps: OptionSet {
    
    public let rawValue: UInt
    
    // -------------------------------------------------------------------------
    /// Calculates the tangents and bitangents for the imported meshes.
    /// Does nothing if a mesh does not have normals. You might want this post
    /// processing step to be executed if you plan to use tangent space
    /// calculations such as normal mapping applied to the meshes.
    public static let calcTangentSpace = PostProcessSteps(rawValue: 0x1)
    
    // -------------------------------------------------------------------------
    /// Identifies and joins identical vertex data sets within all imported
    /// meshes. After this step is run, each mesh contains unique vertices,
    /// so a vertex may be used by multiple faces. You usually want
    /// to use this post processing step. If your application deals with
    /// indexed geometry, this step is compulsory or you'll just waste rendering
    /// time. If this flag is <b>not specified</b>, no vertices are referenced by
    /// more than one face and <b>no index buffer is required</b> for rendering.
    public static let joinIdenticalVertices = PostProcessSteps(rawValue: 0x2)
    
    // -------------------------------------------------------------------------
    /// Converts all the imported data to a left-handed coordinate space.
    /// By default the data is returned in a right-handed coordinate space (which
    /// OpenGL prefers). In this space, +X points to the right,
    /// +Z points towards the viewer, and +Y points upwards. In the DirectX
    /// coordinate space +X points to the right, +Y points upwards, and +Z points
    /// away from the viewer.
    /// You'll probably want to consider this flag if you use Direct3D for
    /// rendering. The AssetImporter_Process_ConvertToLeftHanded flag supersedes this
    /// setting and bundles all conversions typically required for D3D-based
    /// applications.
    public static let makeLeftHanded = PostProcessSteps(rawValue: 0x4)
    
    // -------------------------------------------------------------------------
    /// Triangulates all faces of all meshes.
    /// By default the imported mesh data might contain faces with more than 3
    /// indices. For rendering you'll usually want all faces to be triangles.
    /// This post processing step splits up faces with more than 3 indices into
    /// triangles. Line and point primitives are *not* modified! If you want
    /// 'triangles only' with no other kinds of primitives, try the following
    /// solution: Specify both AssetImporter_Process_Triangulate and #aiProcess_SortByPType
    /// Ignore all point and line meshes when you process assimp's output
    public static let triangulate = PostProcessSteps(rawValue: 0x8)
    
    // -------------------------------------------------------------------------
    /// Removes some parts of the data structure (animations, materials,
    /// light sources, cameras, textures, vertex components).
    /// The  components to be removed are specified in a separate
    /// importer property, <tt>#AI_CONFIG_PP_RVC_FLAGS</tt>. This is quite useful
    /// if you don't need all parts of the output structure. Vertex colors
    /// are rarely used today for example... Calling this step to remove unneeded
    /// data from the pipeline as early as possible results in increased
    /// performance and a more optimized output data structure.
    /// This step is also useful if you want to force Assimp to recompute
    /// normals or tangents. The corresponding steps don't recompute them if
    /// they're already there (loaded from the source asset). By using this
    /// step you can make sure they are NOT there.
    /// This flag is a poor one, mainly because its purpose is usually
    /// misunderstood. Consider the following case: a 3D model has been exported
    /// from a CAD app, and it has per-face vertex colors. Vertex positions can't be
    /// shared, thus the AssetImporter_Process_JoinIdenticalVertices step fails to
    /// optimize the data because of these nasty little vertex colors.
    /// Most apps don't even process them, so it's all for nothing. By using
    /// this step, unneeded components are excluded as early as possible
    /// thus opening more room for internal optimizations.
    public static let removeComponent = PostProcessSteps(rawValue: 0x10)
    
    // -------------------------------------------------------------------------
    /// Generates normals for all faces of all meshes.
    /// This is ignored if normals are already there at the time this flag
    /// is evaluated. Model importers try to load them from the source file, so
    /// they're usually already there. Face normals are shared between all points
    /// of a single face, so a single point can have multiple normals, which
    /// forces the library to duplicate vertices in some cases.
    /// AssetImporter_Process_JoinIdenticalVertices is *senseless* then.
    /// This flag may not be specified together with AssetImporter_Process_GenSmoothNormals.
    public static let genNormals = PostProcessSteps(rawValue: 0x20)
    
    // -------------------------------------------------------------------------
    /// Generates smooth normals for all vertices in the mesh.
    /// This is ignored if normals are already there at the time this flag
    /// is evaluated. Model importers try to load them from the source file, so
    /// they're usually already there.
    /// This flag may not be specified together with
    /// AssetImporter_Process_GenNormals. There's a importer property,
    /// <tt>#AI_CONFIG_PP_GSN_MAX_SMOOTHING_ANGLE</tt> which allows you to specify
    /// an angle maximum for the normal smoothing algorithm. Normals exceeding
    /// this limit are not smoothed, resulting in a 'hard' seam between two faces.
    /// Using a decent angle here (e.g. 80 degrees) results in very good visual
    /// appearance.
    public static let genSmoothNormals = PostProcessSteps(rawValue: 0x40)
    
    // -------------------------------------------------------------------------
    /// Splits large meshes into smaller sub-meshes.
    /// This is quite useful for real-time rendering, where the number of triangles
    /// which can be maximally processed in a single draw-call is limited
    /// by the video driver/hardware. The maximum vertex buffer is usually limited
    /// too. Both requirements can be met with this step: you may specify both a
    /// triangle and vertex limit for a single mesh.
    /// The split limits can (and should!) be set through the
    /// #AI_CONFIG_PP_SLM_VERTEX_LIMIT and #AI_CONFIG_PP_SLM_TRIANGLE_LIMIT
    /// importer properties. The default values are #AI_SLM_DEFAULT_MAX_VERTICES and
    /// #AI_SLM_DEFAULT_MAX_TRIANGLES.
    /// Note that splitting is generally a time-consuming task, but only if there's
    /// something to split. The use of this step is recommended for most users.
    public static let splitLargeMeshes = PostProcessSteps(rawValue: 0x80)
    
    // -------------------------------------------------------------------------
    /// Removes the node graph and pre-transforms all vertices with
    /// the local transformation matrices of their nodes.
    /// The output scene still contains nodes, however there is only a
    /// root node with children, each one referencing only one mesh,
    /// and each mesh referencing one material. For rendering, you can
    /// simply render all meshes in order - you don't need to pay
    /// attention to local transformations and the node hierarchy.
    /// Animations are removed during this step.
    /// This step is intended for applications without a scenegraph.
    /// The step CAN cause some problems: if e.g. a mesh of the asset
    /// contains normals and another, using the same material index, does not,
    /// they will be brought together, but the first meshes's part of
    /// the normal list is zeroed. However, these artifacts are rare.
    /// - Note: The #AI_CONFIG_PP_PTV_NORMALIZE configuration property
    /// can be set to normalize the scene's spatial dimension to the -1...1
    /// range.
    public static let preTransformVertices = PostProcessSteps(rawValue: 0x100)
    
    // -------------------------------------------------------------------------
    /// Limits the number of bones simultaneously affecting a single vertex
    /// to a maximum value.
    /// If any vertex is affected by more than the maximum number of bones, the least
    /// important vertex weights are removed and the remaining vertex weights are
    /// renormalized so that the weights still sum up to 1.
    /// The default bone weight limit is 4 (defined as #AI_LMW_MAX_WEIGHTS in
    /// config.h), but you can use the #AI_CONFIG_PP_LBW_MAX_WEIGHTS importer
    /// property to supply your own limit to the post processing step.
    /// If you intend to perform the skinning in hardware, this post processing
    /// step might be of interest to you.
    public static let limitBoneWeights = PostProcessSteps(rawValue: 0x200)
    
    // -------------------------------------------------------------------------
    /// Validates the imported scene data structure.
    /// This makes sure that all indices are valid, all animations and
    /// bones are linked correctly, all material references are correct .. etc.
    /// It is recommended that you capture Assimp's log output if you use this flag,
    /// so you can easily find out what's wrong if a file fails the
    /// validation. The validator is quite strict and will find *all*
    /// inconsistencies in the data structure... It is recommended that plugin
    /// developers use it to debug their loaders. There are two types of
    /// validation failures:
    ///
    /// <li>Error: There's something wrong with the imported data. Further
    ///   postprocessing is not possible and the data is not usable at all.
    ///   The import fails. #Importer::GetErrorString() or #aiGetErrorString()
    ///   carry the error message around.
    /// Warning: There are some minor issues (e.g. 1000000 animation
    ///   keyframes with the same time), but further postprocessing and use
    ///   of the data structure is still safe. Warning details are written
    ///   to the log file, #AI_SCENE_FLAGS_VALIDATION_WARNING is set
    ///   in #aiScene::mFlags
    ///
    /// This post-processing step is not time-consuming. Its use is not
    /// compulsory, but recommended.
    public static let validateDataStructure = PostProcessSteps(rawValue: 0x400)
    
    // -------------------------------------------------------------------------
    /// Reorders triangles for better vertex cache locality.
    /// The step tries to improve the ACMR (average post-transform vertex cache
    /// miss ratio) for all meshes. The implementation runs in O(n) and is
    /// roughly based on the 'tipsify' algorithm (see
    /// "http://www.cs.princeton.edu/gfx/pubs/Sander_2007_%3ETR/tipsy.pdf" this
    /// paper).
    /// If you intend to render huge models in hardware, this step might
    /// be of interest to you. The <tt>#AI_CONFIG_PP_ICL_PTCACHE_SIZE</tt>
    /// importer property can be used to fine-tune the cache optimization.
    ///
    public static let improveCacheLocality = PostProcessSteps(rawValue: 0x800)
    
    // -------------------------------------------------------------------------
    /// Searches for redundant/unreferenced materials and removes them.
    /// This is especially useful in combination with the
    /// Process_PretransformVertices and Process_OptimizeMeshes flags.
    /// Both join small meshes with equal characteristics, but they can't do
    /// their work if two meshes have different materials. Because several
    /// material settings are lost during Assimp's import filters,
    /// (and because many exporters don't check for redundant materials), huge
    /// models often have materials which are are defined several times with
    /// exactly the same settings.
    /// Several material settings not contributing to the final appearance of
    /// a surface are ignored in all comparisons (e.g. the material name).
    /// So, if you're passing additional information through the
    /// content pipeline (probably using *magic* material names), don't
    /// specify this flag. Alternatively take a look at the
    /// #AI_CONFIG_PP_RRM_EXCLUDE_LIST importer property.
    ///
    public static let removeRedundantMaterials = PostProcessSteps(rawValue: 0x1000)
    
    // -------------------------------------------------------------------------
    /// This step tries to determine which meshes have normal vectors
    /// that are facing inwards and inverts them.
    /// The algorithm is simple but effective:
    /// the bounding box of all vertices + their normals is compared against
    /// the volume of the bounding box of all vertices without their normals.
    /// This works well for most objects, problems might occur with planar
    /// surfaces. However, the step tries to filter such cases.
    /// The step inverts all in-facing normals. Generally it is recommended
    /// to enable this step, although the result is not always correct.
    public static let fixInfacingNormals = PostProcessSteps(rawValue: 0x2000)
    
    // -------------------------------------------------------------------------
    /// This step splits meshes with more than one primitive type in
    /// homogeneous sub-meshes.
    /// The step is executed after the triangulation step. After the step
    /// returns, just one bit is set in aiMesh::mPrimitiveTypes. This is
    /// especially useful for real-time rendering where point and line
    /// primitives are often ignored or rendered separately.
    /// You can use the #AI_CONFIG_PP_SBP_REMOVE importer property to
    /// specify which primitive types you need. This can be used to easily
    /// exclude lines and points, which are rarely used, from the import.
    public static let sortByPType = PostProcessSteps(rawValue: 0x8000)
    
    // -------------------------------------------------------------------------
    /// This step searches all meshes for degenerate primitives and
    /// converts them to proper lines or points.
    /// A face is 'degenerate' if one or more of its points are identical.
    ///
    /// - Note: Degenerate polygons are not necessarily evil and that's why
    /// they're not removed by default. There are several file formats which
    /// don't support lines or points, and some exporters bypass the
    /// format specification and write them as degenerate triangles instead.
    ///
    public static let findDegenerates = PostProcessSteps(rawValue: 0x10000)
    
    // -------------------------------------------------------------------------
    /// This step searches all meshes for invalid data, such as zeroed
    /// normal vectors or invalid UV coords and removes/fixes them. This is
    /// intended to get rid of some common exporter errors.
    /// This is especially useful for normals. If they are invalid, and
    /// the step recognizes this, they will be removed and can later
    /// be recomputed, i.e. by the AssetImporter_Process_GenSmoothNormals flag.
    /// The step will also remove meshes that are infinitely small and reduce
    /// animation tracks consisting of hundreds if redundant keys to a single
    /// key. The AI_CONFIG_PP_FID_ANIM_ACCURACY config property decides
    /// the accuracy of the check for duplicate animation tracks.
    public static let findInvalidData = PostProcessSteps(rawValue: 0x20000)
    
    // -------------------------------------------------------------------------
    /// This step converts non-UV mappings (such as spherical or
    /// cylindrical mapping) to proper texture coordinate channels.
    /// Most applications will support UV mapping only, so you will
    /// probably want to specify this step in every case. Note that Assimp is not
    /// always able to match the original mapping implementation of the
    /// 3D app which produced a model perfectly. It's always better to let the
    /// modelling app compute the UV channels - 3ds max, Maya, Blender,
    /// LightWave, and Modo do this for example.
    /// - Note:
    /// If this step is not requested, you'll need to process the
    /// #AI_MATKEY_MAPPING material property in order to display all
    /// assets properly.
    public static let genUVCoords = PostProcessSteps(rawValue: 0x40000)
    
    // -------------------------------------------------------------------------
    /// This step applies per-texture UV transformations and bakes
    /// them into stand-alone vtexture coordinate channels.
    /// UV transformations are specified per-texture - see the
    /// #AI_MATKEY_UVTRANSFORM material key for more information.
    /// This step processes all textures with
    /// transformed input UV coordinates and generates a new (pre-transformed)
    /// UV Channel which replaces the old channel.
    /// Most applications won't support UV transformations, so you will probably
    /// want to specify this step.
    /// - Note:
    /// UV transformations are usually implemented in real-time apps by
    /// transforming texture coordinates at vertex shader stage with a 3x3
    /// (homogenous) transformation matrix.
    public static let transformUVCoords = PostProcessSteps(rawValue: 0x80000)
    
    // -------------------------------------------------------------------------
    /// This step searches for duplicate meshes and replaces them
    /// with references to the first mesh.
    /// This step takes a while, so don't use it if speed is a concern.
    /// Its main purpose is to workaround the fact that many export
    /// file formats don't support instanced meshes, so exporters need to
    /// duplicate meshes. This step removes the duplicates again. Please
    /// note that Assimp does not currently support per-node material
    /// assignment to meshes, which means that identical meshes with
    /// different materials are currently *not* joined, although this is
    /// planned for future versions.
    public static let findInstances = PostProcessSteps(rawValue: 0x100000)
    
    // -------------------------------------------------------------------------
    /// A postprocessing step to reduce the number of meshes.
    /// This will, in fact, reduce the number of draw calls.
    /// This is a very effective optimization and is recommended to be used
    /// together with AssetImporter_Process_OptimizeGraph, if possible. The flag is fully
    /// compatible with both AssetImporter_Process_SplitLargeMeshes and
    /// AssetImporter_Process_SortByPType.
    public static let optimizeMeshes = PostProcessSteps(rawValue: 0x200000)
    
    // -------------------------------------------------------------------------
    /// A postprocessing step to optimize the scene hierarchy.
    /// Nodes without animations, bones, lights or cameras assigned are
    /// collapsed and joined.
    /// Node names can be lost during this step. If you use special 'tag nodes'
    /// to pass additional information through your content pipeline, use the
    /// #AI_CONFIG_PP_OG_EXCLUDE_LIST importer property to specify a
    /// list of node names you want to be kept. Nodes matching one of the names
    /// in this list won't be touched or modified.
    /// Use this flag with caution. Most simple files will be collapsed to a
    /// single node, so complex hierarchies are usually completely lost. This is
    ///  not useful for editor environments, but probably a very effective
    /// optimization if you just want to get the model data, convert it to your
    /// own format, and render it as fast as possible.
    /// This flag is designed to be used with AssetImporter_Process_OptimizeMeshes for best
    /// results.
    /// - Note:
    /// 'Crappy' scenes with thousands of extremely small meshes packed
    /// in deeply nested nodes exist for almost all file formats.
    /// AssetImporter_Process_OptimizeMeshes in combination with #aiProcess_OptimizeGraph
    /// usually fixes them all and makes them renderable.
    public static let optimizeGraph  = PostProcessSteps(rawValue: 0x400000)
    
    // -------------------------------------------------------------------------
    /// This step flips all UV coordinates along the y-axis and adjusts
    /// material settings and bitangents accordingly.
    /// You'll probably want to consider this flag if you use Direct3D for
    /// rendering. The AssetImporter_Process_ConvertToLeftHanded flag supersedes this
    /// setting and bundles all conversions typically required for D3D-based
    /// applications.
    public static let flipUVs = PostProcessSteps(rawValue: 0x800000)
    
    // -------------------------------------------------------------------------
    /// This step adjusts the output face winding order to be CW.
    /// * The default face winding order is counter clockwise (CCW).
    public static let flipWindingOrder = PostProcessSteps(rawValue: 0x1000000)
    
    // -------------------------------------------------------------------------
    /// This step splits meshes with many bones into sub-meshes so that each
    /// * su-bmesh has fewer or as many bones as a given limit.
    public static let splitByBoneCount = PostProcessSteps(rawValue: 0x2000000)
    
    // -------------------------------------------------------------------------
    /// This step removes bones losslessly or according to some threshold.
    /// In some cases (i.e. formats that require it) exporters are forced to
    /// assign dummy bone weights to otherwise static meshes assigned to
    /// animated meshes. Full, weight-based skinning is expensive while
    /// animating nodes is extremely cheap, so this step is offered to clean up
    /// the data in that regard.
    ///
    /// Use #AI_CONFIG_PP_DB_THRESHOLD to control this.
    /// Use #AI_CONFIG_PP_DB_ALL_OR_NONE if you want bones removed if
    ///   and only if all bones within the scene qualify for removal.
    ///
    public static let debone = PostProcessSteps(rawValue: 0x4000000)
    
    
    // -----------------------------------------------------------------------------
    /// Default postprocess configuration optimizing the data for real-time
    /// rendering.
    /// Contains .process_Triangulate, .process_FlipUVs, .process_SortByPType
    /// flags.
    public static var defaultQuality: PostProcessSteps {
        get {
            return [.triangulate,
                    .flipUVs,
                    .sortByPType]
        }
    }
    
    // -----------------------------------------------------------------------------
    /// Default postprocess configuration optimizing the data for real-time
    /// rendering.
    ///
    /// Applications would want to use this preset to load models on end-user PCs,
    /// maybe for direct use in game.
    ///
    /// If you don't support UV transformations in your application apply the
    /// AssetImporter_Process_TransformUVCoords step, too.
    /// - Note: Please take the time to read the docs for the steps enabled by this
    /// preset.
    /// Some of them offer further configurable properties, while some of them might
    ///  not be of use for you so it might be better to not specify them.
    public static var realtimeFast: PostProcessSteps {
        get {
            return [.calcTangentSpace,
                    .genNormals,
                    .joinIdenticalVertices,
                    .triangulate,
                    .genUVCoords,
                    .sortByPType]
        }
    }
    
    // -----------------------------------------------------------------------------
    /// Default postprocess configuration optimizing the data for real-time
    /// rendering.
    ///
    /// Unlike AssetImporter_ProcessPreset_TargetRealtime_Fast, this configuration
    /// performs some extra optimizations to improve rendering speed and
    /// to minimize memory usage. It could be a good choice for a level editor
    /// environment where import speed is not so important.
    ///
    /// If you don't support UV transformations
    /// in your application apply the AssetImporter_Process_TransformUVCoords step, too.
    /// - Note: Please take the time to read the docs for the steps enabled by this
    /// preset.
    /// Some of them offer further configurable properties, while some of them might
    /// not be of use for you so it might be better to not specify them.
    public static var realtimeQuality: PostProcessSteps {
        get {
            return  [.calcTangentSpace,
                     .genSmoothNormals,
                     .improveCacheLocality,
                     .limitBoneWeights,
                     .removeRedundantMaterials,
                     .splitLargeMeshes,
                     .triangulate,
                     .genUVCoords,
                     .sortByPType,
                     .findDegenerates,
                     .findInvalidData]
        }
    }
    
    
    // ------------------------------------------------------------------------------
    /// Default postprocess configuration optimizing the data for real-time
    /// rendering.
    ///
    /// This preset enables almost every optimization step to achieve perfectly
    /// optimized data. It's your choice for level editor environments where import
    /// speed is not important.
    ///
    /// If you're using DirectX, don't forget to combine this value with the
    /// AssetImporter_Process_ConvertToLeftHanded step. If you don't support UV
    /// transformations in your application, apply the
    /// AssetImporter_Process_TransformUVCoords step, too.
    /// - Note: Please take the time to read the docs for the steps enabled by this preset.
    /// Some of them offer further configurable properties, while some of them might
    /// not be of use for  you so it might be better to not specify them.
    public static var realtimeMaxQuality: PostProcessSteps {
        get {
            return [.realtimeQuality,
                    .findInstances,
                    .validateDataStructure,
                    .optimizeMeshes]
        }
    }
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}

//
//  Material.swift
//  AssetImportKit
//
//  Created by Eugene Bokhan on 2/11/18.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import Assimp

// Name for default materials (2nd is used if meshes have UV coords)
let AI_DEFAULT_MATERIAL_NAME = "DefaultMaterial"

let AI_TEXTURE_TYPE_MAX = aiTextureType_UNKNOWN

// ---------------------------------------------------------------------------
let AI_MATKEY_NAME = (pKey: "?mat.name", type: UInt32(0), index: UInt32(0))
let AI_MATKEY_TWOSIDED = (pKey: "$mat.twosided", type: UInt32(0), index: UInt32(0))
let AI_MATKEY_SHADING_MODEL = (pKey: "$mat.shadingm", type: UInt32(0), index: UInt32(0))
let AI_MATKEY_ENABLE_WIREFRAME = (pKey: "$mat.wireframe", type: UInt32(0), index: UInt32(0))
let AI_MATKEY_BLEND_FUNC = (pKey: "$mat.blend", type: UInt32(0), index: UInt32(0))
let AI_MATKEY_OPACITY = (pKey: "$mat.opacity", type: UInt32(0), index: UInt32(0))
let AI_MATKEY_BUMPSCALING = (pKey: "$mat.bumpscaling", type: UInt32(0), index: UInt32(0))
let AI_MATKEY_SHININESS = (pKey: "$mat.shininess", type: UInt32(0), index: UInt32(0))
let AI_MATKEY_REFLECTIVITY = (pKey: "$mat.reflectivity", type: UInt32(0), index: UInt32(0))
let AI_MATKEY_SHININESS_STRENGTH = (pKey: "$mat.shinpercent", type: UInt32(0), index: UInt32(0))
let AI_MATKEY_REFRACTI = (pKey: "$mat.refracti", type: UInt32(0), index: UInt32(0))
let AI_MATKEY_COLOR_DIFFUSE = (pKey: "$clr.diffuse", type: UInt32(0), index: UInt32(0))
let AI_MATKEY_COLOR_AMBIENT  = (pKey: "$clr.ambient", type: UInt32(0), index: UInt32(0))
let AI_MATKEY_COLOR_SPECULAR  = (pKey: "$clr.specular", type: UInt32(0), index: UInt32(0))
let AI_MATKEY_COLOR_EMISSIVE  = (pKey: "$clr.emissive", type: UInt32(0), index: UInt32(0))
let AI_MATKEY_COLOR_TRANSPARENT = (pKey: "$clr.transparent", type: UInt32(0), index: UInt32(0))
let AI_MATKEY_COLOR_REFLECTIVE = (pKey: "$clr.reflective", type: UInt32(0), index: UInt32(0))
let AI_MATKEY_GLOBAL_BACKGROUND_IMAGE = (pKey: "?bg.global", type: UInt32(0), index: UInt32(0))

// ---------------------------------------------------------------------------
// Pure key names for all texture-related properties
//! @cond MATS_DOC_FULL
let _AI_MATKEY_TEXTURE_BASE = "$tex.file"
let _AI_MATKEY_UVWSRC_BASE = "$tex.uvwsrc"
let _AI_MATKEY_TEXOP_BASE = "$tex.op"
let _AI_MATKEY_MAPPING_BASE = "$tex.mapping"
let _AI_MATKEY_TEXBLEND_BASE = "$tex.blend"
let _AI_MATKEY_MAPPINGMODE_U_BASE = "$tex.mapmodeu"
let _AI_MATKEY_MAPPINGMODE_V_BASE = "$tex.mapmodev"
let _AI_MATKEY_TEXMAP_AXIS_BASE = "$tex.mapaxis"
let _AI_MATKEY_UVTRANSFORM_BASE = "$tex.uvtrafo"
let _AI_MATKEY_TEXFLAGS_BASE = "$tex.flags"
//! @endcond

// ---------------------------------------------------------------------------
func AI_MATKEY_TEXTURE(_ type: aiTextureType, _ N: UInt32) -> (String, aiTextureType, UInt32) { return (_AI_MATKEY_TEXTURE_BASE, type, N) }

// For backward compatibility and simplicity
//! @cond MATS_DOC_FULL
func AI_MATKEY_TEXTURE_DIFFUSE(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXTURE(aiTextureType_DIFFUSE,N) }

func AI_MATKEY_TEXTURE_SPECULAR(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXTURE(aiTextureType_SPECULAR,N) }

func AI_MATKEY_TEXTURE_AMBIENT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXTURE(aiTextureType_AMBIENT,N) }

func AI_MATKEY_TEXTURE_EMISSIVE(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXTURE(aiTextureType_EMISSIVE,N) }

func AI_MATKEY_TEXTURE_NORMALS(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXTURE(aiTextureType_NORMALS,N) }

func AI_MATKEY_TEXTURE_HEIGHT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXTURE(aiTextureType_HEIGHT,N) }

func AI_MATKEY_TEXTURE_SHININESS(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXTURE(aiTextureType_SHININESS,N) }

func AI_MATKEY_TEXTURE_OPACITY(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXTURE(aiTextureType_OPACITY,N) }

func AI_MATKEY_TEXTURE_DISPLACEMENT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXTURE(aiTextureType_DISPLACEMENT,N) }

func AI_MATKEY_TEXTURE_LIGHTMAP(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXTURE(aiTextureType_LIGHTMAP,N) }

func AI_MATKEY_TEXTURE_REFLECTION(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXTURE(aiTextureType_REFLECTION,N) }

//! @endcond

// ---------------------------------------------------------------------------
func AI_MATKEY_UVWSRC(_ type: aiTextureType, _ N: UInt32) -> (String, aiTextureType, UInt32) { return (_AI_MATKEY_UVWSRC_BASE, type, N) }

// For backward compatibility and simplicity
//! @cond MATS_DOC_FULL
func AI_MATKEY_UVWSRC_DIFFUSE(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_UVWSRC(aiTextureType_DIFFUSE,N) }

func AI_MATKEY_UVWSRC_SPECULAR(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_UVWSRC(aiTextureType_SPECULAR,N) }

func AI_MATKEY_UVWSRC_AMBIENT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_UVWSRC(aiTextureType_AMBIENT,N) }

func AI_MATKEY_UVWSRC_EMISSIVE(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_UVWSRC(aiTextureType_EMISSIVE,N) }

func AI_MATKEY_UVWSRC_NORMALS(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_UVWSRC(aiTextureType_NORMALS,N) }

func AI_MATKEY_UVWSRC_HEIGHT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_UVWSRC(aiTextureType_HEIGHT,N) }

func AI_MATKEY_UVWSRC_SHININESS(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_UVWSRC(aiTextureType_SHININESS,N) }

func AI_MATKEY_UVWSRC_OPACITY(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_UVWSRC(aiTextureType_OPACITY,N) }

func AI_MATKEY_UVWSRC_DISPLACEMENT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_UVWSRC(aiTextureType_DISPLACEMENT,N) }

func AI_MATKEY_UVWSRC_LIGHTMAP(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_UVWSRC(aiTextureType_LIGHTMAP,N) }

func AI_MATKEY_UVWSRC_REFLECTION(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_UVWSRC(aiTextureType_REFLECTION,N) }

//! @endcond
// ---------------------------------------------------------------------------
func AI_MATKEY_TEXOP(_ type: aiTextureType, _ N: UInt32) -> (String, aiTextureType, UInt32) { return (_AI_MATKEY_TEXOP_BASE, type, N) }

// For backward compatibility and simplicity
//! @cond MATS_DOC_FULL
func AI_MATKEY_TEXOP_DIFFUSE(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXOP(aiTextureType_DIFFUSE,N) }

func AI_MATKEY_TEXOP_SPECULAR(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXOP(aiTextureType_SPECULAR,N) }

func AI_MATKEY_TEXOP_AMBIENT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXOP(aiTextureType_AMBIENT,N) }

func AI_MATKEY_TEXOP_EMISSIVE(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXOP(aiTextureType_EMISSIVE,N) }

func AI_MATKEY_TEXOP_NORMALS(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXOP(aiTextureType_NORMALS,N) }

func AI_MATKEY_TEXOP_HEIGHT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXOP(aiTextureType_HEIGHT,N) }

func AI_MATKEY_TEXOP_SHININESS(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXOP(aiTextureType_SHININESS,N) }

func AI_MATKEY_TEXOP_OPACITY(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXOP(aiTextureType_OPACITY,N) }

func AI_MATKEY_TEXOP_DISPLACEMENT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXOP(aiTextureType_DISPLACEMENT,N) }

func AI_MATKEY_TEXOP_LIGHTMAP(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXOP(aiTextureType_LIGHTMAP,N) }

func AI_MATKEY_TEXOP_REFLECTION(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXOP(aiTextureType_REFLECTION,N) }

//! @endcond
// ---------------------------------------------------------------------------
func AI_MATKEY_MAPPING(_ type: aiTextureType, _ N: UInt32) -> (String, aiTextureType, UInt32) { return (_AI_MATKEY_MAPPING_BASE, type, N) }

// For backward compatibility and simplicity
//! @cond MATS_DOC_FULL
func AI_MATKEY_MAPPING_DIFFUSE(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPING(aiTextureType_DIFFUSE,N) }

func AI_MATKEY_MAPPING_SPECULAR(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPING(aiTextureType_SPECULAR,N) }

func AI_MATKEY_MAPPING_AMBIENT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPING(aiTextureType_AMBIENT,N) }

func AI_MATKEY_MAPPING_EMISSIVE(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPING(aiTextureType_EMISSIVE,N) }

func AI_MATKEY_MAPPING_NORMALS(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPING(aiTextureType_NORMALS,N) }

func AI_MATKEY_MAPPING_HEIGHT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPING(aiTextureType_HEIGHT,N) }

func AI_MATKEY_MAPPING_SHININESS(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPING(aiTextureType_SHININESS,N) }

func AI_MATKEY_MAPPING_OPACITY(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPING(aiTextureType_OPACITY,N) }

func AI_MATKEY_MAPPING_DISPLACEMENT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPING(aiTextureType_DISPLACEMENT,N) }

func AI_MATKEY_MAPPING_LIGHTMAP(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPING(aiTextureType_LIGHTMAP,N) }

func AI_MATKEY_MAPPING_REFLECTION(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPING(aiTextureType_REFLECTION,N) }

//! @endcond
// ---------------------------------------------------------------------------
func AI_MATKEY_TEXBLEND(_ type: aiTextureType, _ N: UInt32) -> (String, aiTextureType, UInt32) { return (_AI_MATKEY_TEXBLEND_BASE, type, N) }

// For backward compatibility and simplicity
//! @cond MATS_DOC_FULL
func AI_MATKEY_TEXBLEND_DIFFUSE(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXBLEND(aiTextureType_DIFFUSE,N) }

func AI_MATKEY_TEXBLEND_SPECULAR(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXBLEND(aiTextureType_SPECULAR,N) }

func AI_MATKEY_TEXBLEND_AMBIENT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXBLEND(aiTextureType_AMBIENT,N) }

func AI_MATKEY_TEXBLEND_EMISSIVE(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXBLEND(aiTextureType_EMISSIVE,N) }

func AI_MATKEY_TEXBLEND_NORMALS(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXBLEND(aiTextureType_NORMALS,N) }

func AI_MATKEY_TEXBLEND_HEIGHT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXBLEND(aiTextureType_HEIGHT,N) }

func AI_MATKEY_TEXBLEND_SHININESS(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXBLEND(aiTextureType_SHININESS,N) }

func AI_MATKEY_TEXBLEND_OPACITY(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXBLEND(aiTextureType_OPACITY,N) }

func AI_MATKEY_TEXBLEND_DISPLACEMENT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXBLEND(aiTextureType_DISPLACEMENT,N) }

func AI_MATKEY_TEXBLEND_LIGHTMAP(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXBLEND(aiTextureType_LIGHTMAP,N) }

func AI_MATKEY_TEXBLEND_REFLECTION(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXBLEND(aiTextureType_REFLECTION,N) }

//! @endcond
// ---------------------------------------------------------------------------
func AI_MATKEY_MAPPINGMODE_U(_ type: aiTextureType, _ N: UInt32) -> (String, aiTextureType, UInt32) { return (_AI_MATKEY_MAPPINGMODE_U_BASE, type, N) }

// For backward compatibility and simplicity
//! @cond MATS_DOC_FULL
func AI_MATKEY_MAPPINGMODE_U_DIFFUSE(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPINGMODE_U(aiTextureType_DIFFUSE,N) }

func AI_MATKEY_MAPPINGMODE_U_SPECULAR(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPINGMODE_U(aiTextureType_SPECULAR,N) }

func AI_MATKEY_MAPPINGMODE_U_AMBIENT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPINGMODE_U(aiTextureType_AMBIENT,N) }

func AI_MATKEY_MAPPINGMODE_U_EMISSIVE(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPINGMODE_U(aiTextureType_EMISSIVE,N) }

func AI_MATKEY_MAPPINGMODE_U_NORMALS(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPINGMODE_U(aiTextureType_NORMALS,N) }

func AI_MATKEY_MAPPINGMODE_U_HEIGHT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPINGMODE_U(aiTextureType_HEIGHT,N) }

func AI_MATKEY_MAPPINGMODE_U_SHININESS(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPINGMODE_U(aiTextureType_SHININESS,N) }

func AI_MATKEY_MAPPINGMODE_U_OPACITY(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPINGMODE_U(aiTextureType_OPACITY,N) }

func AI_MATKEY_MAPPINGMODE_U_DISPLACEMENT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPINGMODE_U(aiTextureType_DISPLACEMENT,N) }

func AI_MATKEY_MAPPINGMODE_U_LIGHTMAP(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPINGMODE_U(aiTextureType_LIGHTMAP,N) }

func AI_MATKEY_MAPPINGMODE_U_REFLECTION(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPINGMODE_U(aiTextureType_REFLECTION,N) }

//! @endcond
// ---------------------------------------------------------------------------
func AI_MATKEY_MAPPINGMODE_V(_ type: aiTextureType, _ N: UInt32) -> (String, aiTextureType, UInt32) { return (_AI_MATKEY_MAPPINGMODE_V_BASE, type, N) }

// For backward compatibility and simplicity
//! @cond MATS_DOC_FULL
func AI_MATKEY_MAPPINGMODE_V_DIFFUSE(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPINGMODE_V(aiTextureType_DIFFUSE,N) }

func AI_MATKEY_MAPPINGMODE_V_SPECULAR(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPINGMODE_V(aiTextureType_SPECULAR,N) }

func AI_MATKEY_MAPPINGMODE_V_AMBIENT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPINGMODE_V(aiTextureType_AMBIENT,N) }

func AI_MATKEY_MAPPINGMODE_V_EMISSIVE(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPINGMODE_V(aiTextureType_EMISSIVE,N) }

func AI_MATKEY_MAPPINGMODE_V_NORMALS(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPINGMODE_V(aiTextureType_NORMALS,N) }

func AI_MATKEY_MAPPINGMODE_V_HEIGHT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPINGMODE_V(aiTextureType_HEIGHT,N) }

func AI_MATKEY_MAPPINGMODE_V_SHININESS(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPINGMODE_V(aiTextureType_SHININESS,N) }

func AI_MATKEY_MAPPINGMODE_V_OPACITY(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPINGMODE_V(aiTextureType_OPACITY,N) }

func AI_MATKEY_MAPPINGMODE_V_DISPLACEMENT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPINGMODE_V(aiTextureType_DISPLACEMENT,N) }

func AI_MATKEY_MAPPINGMODE_V_LIGHTMAP(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPINGMODE_V(aiTextureType_LIGHTMAP,N) }

func AI_MATKEY_MAPPINGMODE_V_REFLECTION(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_MAPPINGMODE_V(aiTextureType_REFLECTION,N) }

//! @endcond
// ---------------------------------------------------------------------------
func AI_MATKEY_TEXMAP_AXIS(_ type: aiTextureType, _ N: UInt32) -> (String, aiTextureType, UInt32) { return (_AI_MATKEY_TEXMAP_AXIS_BASE, type, N) }

// For backward compatibility and simplicity
//! @cond MATS_DOC_FULL
func AI_MATKEY_TEXMAP_AXIS_DIFFUSE(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXMAP_AXIS(aiTextureType_DIFFUSE,N) }

func AI_MATKEY_TEXMAP_AXIS_SPECULAR(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXMAP_AXIS(aiTextureType_SPECULAR,N) }

func AI_MATKEY_TEXMAP_AXIS_AMBIENT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXMAP_AXIS(aiTextureType_AMBIENT,N) }

func AI_MATKEY_TEXMAP_AXIS_EMISSIVE(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXMAP_AXIS(aiTextureType_EMISSIVE,N) }

func AI_MATKEY_TEXMAP_AXIS_NORMALS(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXMAP_AXIS(aiTextureType_NORMALS,N) }

func AI_MATKEY_TEXMAP_AXIS_HEIGHT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXMAP_AXIS(aiTextureType_HEIGHT,N) }

func AI_MATKEY_TEXMAP_AXIS_SHININESS(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXMAP_AXIS(aiTextureType_SHININESS,N) }

func AI_MATKEY_TEXMAP_AXIS_OPACITY(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXMAP_AXIS(aiTextureType_OPACITY,N) }

func AI_MATKEY_TEXMAP_AXIS_DISPLACEMENT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXMAP_AXIS(aiTextureType_DISPLACEMENT,N) }

func AI_MATKEY_TEXMAP_AXIS_LIGHTMAP(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXMAP_AXIS(aiTextureType_LIGHTMAP,N) }

func AI_MATKEY_TEXMAP_AXIS_REFLECTION(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXMAP_AXIS(aiTextureType_REFLECTION,N) }

//! @endcond
// ---------------------------------------------------------------------------
func AI_MATKEY_UVTRANSFORM(_ type: aiTextureType, _ N: UInt32) -> (String, aiTextureType, UInt32) { return (_AI_MATKEY_UVTRANSFORM_BASE, type, N) }

// For backward compatibility and simplicity
//! @cond MATS_DOC_FULL
func AI_MATKEY_UVTRANSFORM_DIFFUSE(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_UVTRANSFORM(aiTextureType_DIFFUSE,N) }

func AI_MATKEY_UVTRANSFORM_SPECULAR(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_UVTRANSFORM(aiTextureType_SPECULAR,N) }

func AI_MATKEY_UVTRANSFORM_AMBIENT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_UVTRANSFORM(aiTextureType_AMBIENT,N) }

func AI_MATKEY_UVTRANSFORM_EMISSIVE(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_UVTRANSFORM(aiTextureType_EMISSIVE,N) }

func AI_MATKEY_UVTRANSFORM_NORMALS(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_UVTRANSFORM(aiTextureType_NORMALS,N) }

func AI_MATKEY_UVTRANSFORM_HEIGHT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_UVTRANSFORM(aiTextureType_HEIGHT,N) }

func AI_MATKEY_UVTRANSFORM_SHININESS(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_UVTRANSFORM(aiTextureType_SHININESS,N) }

func AI_MATKEY_UVTRANSFORM_OPACITY(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_UVTRANSFORM(aiTextureType_OPACITY,N) }

func AI_MATKEY_UVTRANSFORM_DISPLACEMENT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_UVTRANSFORM(aiTextureType_DISPLACEMENT,N) }

func AI_MATKEY_UVTRANSFORM_LIGHTMAP(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_UVTRANSFORM(aiTextureType_LIGHTMAP,N) }

func AI_MATKEY_UVTRANSFORM_REFLECTION(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_UVTRANSFORM(aiTextureType_REFLECTION,N) }

func AI_MATKEY_UVTRANSFORM_UNKNOWN(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_UVTRANSFORM(aiTextureType_UNKNOWN,N) }

//! @endcond
// ---------------------------------------------------------------------------
func AI_MATKEY_TEXFLAGS(_ type: aiTextureType, _ N: UInt32) -> (String, aiTextureType, UInt32) { return (_AI_MATKEY_TEXFLAGS_BASE, type, N) }

// For backward compatibility and simplicity
//! @cond MATS_DOC_FULL
func AI_MATKEY_TEXFLAGS_DIFFUSE(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXFLAGS(aiTextureType_DIFFUSE,N) }

func AI_MATKEY_TEXFLAGS_SPECULAR(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXFLAGS(aiTextureType_SPECULAR,N) }

func AI_MATKEY_TEXFLAGS_AMBIENT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXFLAGS(aiTextureType_AMBIENT,N) }

func AI_MATKEY_TEXFLAGS_EMISSIVE(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXFLAGS(aiTextureType_EMISSIVE,N) }

func AI_MATKEY_TEXFLAGS_NORMALS(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXFLAGS(aiTextureType_NORMALS,N) }

func AI_MATKEY_TEXFLAGS_HEIGHT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXFLAGS(aiTextureType_HEIGHT,N) }

func AI_MATKEY_TEXFLAGS_SHININESS(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXFLAGS(aiTextureType_SHININESS,N) }

func AI_MATKEY_TEXFLAGS_OPACITY(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXFLAGS(aiTextureType_OPACITY,N) }

func AI_MATKEY_TEXFLAGS_DISPLACEMENT(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXFLAGS(aiTextureType_DISPLACEMENT,N) }

func AI_MATKEY_TEXFLAGS_LIGHTMAP(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXFLAGS(aiTextureType_LIGHTMAP,N) }

func AI_MATKEY_TEXFLAGS_REFLECTION(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXFLAGS(aiTextureType_REFLECTION,N) }

func AI_MATKEY_TEXFLAGS_UNKNOWN(_ N: UInt32) -> (String, aiTextureType, UInt32) { return AI_MATKEY_TEXFLAGS(aiTextureType_UNKNOWN,N) }

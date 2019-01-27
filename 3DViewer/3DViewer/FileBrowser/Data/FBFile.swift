//
//  FBFile.swift
//  3DViewer
//
//  Created by Eugene Bokhan on 9/14/17.
//  Copyright © 2017 Eugene Bokhan. All rights reserved.
//

import Foundation
import UIKit

// FBFile is a class representing a file in FileBrowser
open class FBFile: NSObject, NSCoding {
    
    /// Display name. String.
    public let displayName: String
    // is Directory. Bool.
    public let isDirectory: Bool
    /// File extension.
    public let fileExtension: String?
    /// File attributes (including size, creation date etc).
    public let fileAttributes: NSDictionary?
    /// NSURL file path.
    public var filePath: URL
    // FBFileType
    public let type: FBFileType
    
    open func delete()
    {
        do
        {
            try FileManager.default.removeItem(at: self.filePath)
        }
        catch
        {
            print("An error occured when trying to delete file:\(self.filePath) Error:\(error)")
        }
    }
    
    /**
     Initialize an FBFile object with a filePath
     
     - parameter filePath: NSURL filePath
     
     - returns: FBFile object.
     */
    init(filePath: URL) {
        self.filePath = filePath
        let isDirectory = checkDirectory(filePath)
        self.isDirectory = isDirectory
        if self.isDirectory {
            self.fileAttributes = nil
            self.fileExtension = nil
            self.type = .Directory
        }
        else {
            self.fileAttributes = getFileAttributes(self.filePath)
            self.fileExtension = filePath.pathExtension
            if let fileExtension = fileExtension {
                self.type = FBFileType(rawValue: fileExtension) ?? .Default
            }
            else {
                self.type = .Default
            }
        }
        self.displayName = filePath.lastPathComponent
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(filePath, forKey: "filePath")
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {

        guard let filePath = aDecoder.decodeObject(forKey: "filePath") as? URL
            else {
                return nil
        }
        
        self.init(filePath: filePath)
    }
    
    // Selector for UILocalizedIndexedCollation sort
    
    @objc open func returnDisplayName() ->NSString {
        return self.displayName as NSString
    }
}

// MARK: -  FBFile type

public enum FBFileType: String {
    /// Directory
    case Directory = "directory"
    /// GIF file
    case GIF = "gif"
    /// JPG file
    case JPG = "jpg"
    /// PLIST file
    case JSON = "json"
    /// PDF file
    case PDF = "pdf"
    /// PLIST file
    case PLIST = "plist"
    /// PNG file
    case PNG = "png"
    /// ZIP file
    case ZIP = "zip"
    /// DAE file
    case DAE = "dae"
    /// FBX file
    case FBX = "fbx"
    /// OBJ file
    case OBJ = "obj"
    /// SCN file
    case SCN = "scn"
    /// MD3 file
    case MD3 = "md3"
    /// ZGL file
    case ZGL = "zgl"
    /// XGL file
    case XGL = "xgl"
    /// WRL file
    case WRL = "wrl"
    /// STL file
    case STL = "stl"
    /// SMD file
    case SMD = "smd"
    /// RAW file
    case RAW = "raw"
    /// Q3S file
    case Q3S = "q3s"
    /// Q3O file
    case Q3O = "q3o"
    /// PLY file
    case PLY = "ply"
    /// XML file
    case XML = "xml"
    /// MESH file
    case MESH = "mesh"
    /// OFF file
    case OFF = "off"
    /// NFF file
    case NFF = "nff"
    /// M3SD file
    case M3SD = "m3sd"
    /// MD5ANIM file
    case MD5ANIM = "md5anim"
    /// MD5MESH file
    case MD5MESH = "md5mesh"
    /// MD2 file
    case MD2 = "md2"
    /// IRR file
    case IRR = "irr"
    /// IFC file
    case IFC = "ifc"
    /// DXF file
    case DXF = "dxf"
    /// COB file
    case COB = "cob"
    /// BVH file
    case BVH = "bvh"
    /// B3D file
    case B3D = "b3d"
    /// AC file
    case AC = "ac"
    /// BLEND file
    case BLEND = "blend"
    /// HMP file
    case HMP = "hmp"
    /// 3DS file
    case _3DS = "3ds"
    /// 3D file
    case _3D = "3d"
    /// X file
    case X = "x"
    /// TER file
    case TER = "ter"
    /// MAX file
    case MAX = "max"
    /// MS3D file
    case MS3D = "ms3d"
    /// MDL file
    case MDL = "mdl"
    /// ASE file
    case ASE = "ase"
    /// GLTF file
    case GLTF = "gltf"
    /// Any file
    case Default = "file"
    
    /**
     Get representative image for file type
     
     - returns: UIImage for file type
     */
    public func image() -> UIImage? {
        let bundle =  Bundle(for: FileParser.self)
        var fileName = String()
        switch self {
        case .Directory: fileName = "folder@2x.png"
        case .JPG, .PNG, .GIF: fileName = "image@2x.png"
        case .PDF: fileName = "pdf@2x.png"
        case .ZIP: fileName = "zip@2x.png"
        case .OBJ, .DAE, .FBX, .SCN, .MD3, .ZGL, .XGL, .WRL, .STL, .SMD, .RAW, .Q3S, .Q3O, .PLY, .XML, .MESH, .OFF, .NFF, .M3SD, .MD5ANIM, .MD5MESH, .MD2, .IRR, .IFC, .DXF, .COB, .BVH, .B3D, .AC, .BLEND, .HMP, ._3DS, ._3D, .X, .TER, .MAX, .MS3D, .MDL, .ASE, .GLTF: fileName = "scene@2x.png"
        default: fileName = "file@2x.png"
        }
        let file = UIImage(named: fileName, in: bundle, compatibleWith: nil)
        return file
    }
}

/**
 Check if file path NSURL is directory or file.
 
 - parameter filePath: NSURL file path.
 
 - returns: isDirectory Bool.
 */
func checkDirectory(_ filePath: URL) -> Bool {
    var isDirectory = false
    do {
        var resourceValue: AnyObject?
        try (filePath as NSURL).getResourceValue(&resourceValue, forKey: URLResourceKey.isDirectoryKey)
        if let number = resourceValue as? NSNumber , number == true {
            isDirectory = true
        }
    }
    catch { }
    return isDirectory
}

func getFileAttributes(_ filePath: URL) -> NSDictionary? {
    let path = filePath.path
    let fileManager = FileParser.sharedInstance.fileManager
    do {
        let attributes = try fileManager.attributesOfItem(atPath: path) as NSDictionary
        return attributes
    } catch {}
    return nil
}

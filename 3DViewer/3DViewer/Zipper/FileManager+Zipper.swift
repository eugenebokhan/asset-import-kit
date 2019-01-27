
import Foundation

public extension FileManager {
    public typealias CentralDirectoryStructure = Zipper.Entry.CentralDirectoryStructure

    /// Zips the file or direcory contents at the specified source URL to the destination URL.
    ///
    /// If the item at the source URL is a directory, the directory itself will be
    /// represented within the ZIP `Zipper`. Calling this method with a directory URL
    /// `file:///path/directory/` will create an archive with a `directory/` entry at the root level.
    /// You can override this behavior by passing `false` for `shouldKeepParent`. In that case, the contents
    /// of the source directory will be placed at the root of the archive.
    /// - Parameters:
    ///   - sourceURL: The file URL pointing to an existing file or directory.
    ///   - destinationURL: The file URL that identifies the destination of the zip operation.
    ///   - shouldKeepParent: Indicates that the directory name of a source item should be used as root element
    ///                       within the archive. Default is `true`.
    /// - Throws: Throws an error if the source item does not exist or the destination URL is not writable.
    public func zip(item sourceURL: URL, to destinationURL: URL, shouldKeepParent: Bool = true) throws {
        guard !self.fileExists(atPath: destinationURL.path) else {
            throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.fileWriteFileExists.rawValue,
                          userInfo: [NSFilePathErrorKey: destinationURL.path])
        }
        guard let archive = Zipper(url: destinationURL, accessMode: .create) else {
            throw Zipper.ArchiveError.unwritableArchive
        }
        try archive.archive(item: sourceURL)
    }

    /// Unzips the contents at the specified source URL to the destination URL.
    ///
    /// - Parameters:
    ///   - sourceURL: The file URL pointing to an existing ZIP file.
    ///   - destinationURL: The file URL that identifies the destination of the unzip operation.
    /// - Throws: Throws an error if the source item does not exist or the destination URL is not writable.
    public func unzip(item sourceURL: URL, to destinationURL: URL) throws {
        guard let archive = Zipper(url: sourceURL, accessMode: .read) else {
            throw Zipper.ArchiveError.unreadableArchive
        }
        try archive.extract(to: destinationURL)
    }

    // MARK: - Helpers

    public func createParentDirectoryStructure(for url: URL) throws {
        let parentDirectoryURL = url.deletingLastPathComponent()
        if !self.fileExists(atPath: parentDirectoryURL.path) {
            try self.createDirectory(at: parentDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }
    }

    public class func attributes(from centralDirectoryStructure: CentralDirectoryStructure) -> [FileAttributeKey : Any] {
        var attributes = [.posixPermissions: defaultPermissions,
                          .modificationDate: Date()] as [FileAttributeKey : Any]
        let versionMadeBy = centralDirectoryStructure.versionMadeBy
        let fileTime = centralDirectoryStructure.lastModFileTime
        let fileDate = centralDirectoryStructure.lastModFileDate
        guard let osType = Zipper.Entry.OSType(rawValue: UInt(versionMadeBy >> 8)) else {
            return attributes
        }
        let externalFileAttributes = centralDirectoryStructure.externalFileAttributes
        attributes[.posixPermissions] = self.permissions(for: externalFileAttributes, osType: osType)
        attributes[.modificationDate] = Date(dateTime: (fileDate, fileTime))
        return attributes
    }

    public class func permissions(for externalFileAttributes: UInt32, osType: Zipper.Entry.OSType) -> UInt16 {
        switch osType {
        case .unix, .osx:
            let permissions = mode_t(externalFileAttributes >> 16) & (~S_IFMT)
            return permissions == 0 ? defaultPermissions : UInt16(permissions)
        default:
            return defaultPermissions
        }
    }

    public class func externalFileAttributesForEntry(of type: Zipper.Entry.EntryType, permissions: UInt16) -> UInt32 {
        var typeInt: UInt16
        switch type {
        case .file:
            typeInt = UInt16(S_IFREG)
        case .directory:
            typeInt = UInt16(S_IFDIR)
        case .symlink:
            typeInt = UInt16(S_IFLNK)
        }
        var externalFileAttributes = UInt32(typeInt|UInt16(permissions))
        externalFileAttributes = (externalFileAttributes << 16)
        return externalFileAttributes
    }

    public class func permissionsForItem(at URL: URL) throws -> UInt16 {
        let fileManager = FileManager()
        let entryFileSystemRepresentation = fileManager.fileSystemRepresentation(withPath: URL.path)
        var fileStat = stat()
        lstat(entryFileSystemRepresentation, &fileStat)
        let permissions = fileStat.st_mode
        return UInt16(permissions)
    }

    class func fileModificationDateTimeForItem(at url: URL) throws -> Date {
        let fileManager = FileManager()
        guard fileManager.fileExists(atPath: url.path) else {
            throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.fileReadNoSuchFile.rawValue,
                          userInfo: [NSFilePathErrorKey: url.path])
        }
        let entryFileSystemRepresentation = fileManager.fileSystemRepresentation(withPath: url.path)
        var fileStat = stat()
        lstat(entryFileSystemRepresentation, &fileStat)
#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
        let modTimeSpec = fileStat.st_mtimespec
#else
        let modTimeSpec = fileStat.st_mtim
#endif

        let timeStamp = TimeInterval(modTimeSpec.tv_sec) + TimeInterval(modTimeSpec.tv_nsec)/1000000000.0
        let modDate = Date(timeIntervalSince1970: timeStamp)
        return modDate
    }

    class func fileSizeForItem(at url: URL) throws -> UInt32 {
        let fileManager = FileManager()
        guard fileManager.fileExists(atPath: url.path) else {
            throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.fileReadNoSuchFile.rawValue,
                          userInfo: [NSFilePathErrorKey: url.path])
        }
        let entryFileSystemRepresentation = fileManager.fileSystemRepresentation(withPath: url.path)
        var fileStat = stat()
        lstat(entryFileSystemRepresentation, &fileStat)
        return UInt32(fileStat.st_size)
    }

    class func typeForItem(at url: URL) throws -> Zipper.Entry.EntryType {
        let fileManager = FileManager()
        guard fileManager.fileExists(atPath: url.path) else {
            throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.fileReadNoSuchFile.rawValue,
                          userInfo: [NSFilePathErrorKey: url.path])
        }
        let entryFileSystemRepresentation = fileManager.fileSystemRepresentation(withPath: url.path)
        var fileStat = stat()
        lstat(entryFileSystemRepresentation, &fileStat)
        return Zipper.Entry.EntryType(mode: fileStat.st_mode)
    }
}

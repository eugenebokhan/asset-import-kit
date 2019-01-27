
import Foundation

public extension Zipper {
    /// Read a ZIP `Zipper.Entry` from the receiver and write it to `url`.
    ///
    /// - Parameters:
    ///   - entry: The ZIP `Zipper.Entry` to read.
    ///   - url: The destination file URL.
    ///   - bufferSize: The maximum size of the read buffer and the decompression buffer (if needed).
    /// - Returns: The checksum of the processed content.
    /// - Throws: An error if the destination file cannot be written or the entry contains malformed content.
    public func extract(_ entry: Zipper.Entry, to url: URL, bufferSize: UInt32 = defaultReadChunkSize) throws -> ZipperCRC32 {
        let fileManager = FileManager()
        var checksum = ZipperCRC32(0)
        switch entry.type {
        case .file:
            guard !fileManager.fileExists(atPath: url.path) else {
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.fileWriteFileExists.rawValue,
                              userInfo: [NSFilePathErrorKey: url.path])
            }
            try fileManager.createParentDirectoryStructure(for: url)
            let destinationFileSystemRepresentation = fileManager.fileSystemRepresentation(withPath: url.path)
            let destinationFile: UnsafeMutablePointer<FILE> = fopen(destinationFileSystemRepresentation, "wb+")
            defer { fclose(destinationFile) }
            let consumer = { _ = try Data.write(chunk: $0, to: destinationFile) }
            checksum = try self.extract(entry, bufferSize: bufferSize, consumer: consumer)
        case .directory:
            let consumer = { (_: Data) in
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            }
            checksum = try self.extract(entry, bufferSize: bufferSize, consumer: consumer)
        case .symlink:
            guard !fileManager.fileExists(atPath: url.path) else {
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.fileWriteFileExists.rawValue,
                              userInfo: [NSFilePathErrorKey: url.path])
            }
            let consumer = { (data: Data) in
                guard let linkPath = String(data: data, encoding: .utf8) else { throw ArchiveError.invalidEntryPath }
                try fileManager.createParentDirectoryStructure(for: url)
                try fileManager.createSymbolicLink(atPath: url.path, withDestinationPath: linkPath)
            }
            checksum = try self.extract(entry, bufferSize: bufferSize, consumer: consumer)
        }
        let attributes = FileManager.attributes(from: entry.centralDirectoryStructure)
        try fileManager.setAttributes(attributes, ofItemAtPath: url.path)
        return checksum
    }

    /// Read a ZIP `Zipper.Entry` from the receiver and forward its contents to a `ZipperConsumerClosure` closure.
    ///
    /// - Parameters:
    ///   - entry: The ZIP `Zipper.Entry` to read.
    ///   - bufferSize: The maximum size of the read buffer and the decompression buffer (if needed).
    ///   - consumer: A closure that consumes contents of `Zipper.Entry` as `Data` chunks.
    /// - Returns: The checksum of the processed content.
    /// - Throws: An error if the destination file cannot be written or the entry contains malformed content.
    public func extract(_ entry: Zipper.Entry, bufferSize: UInt32 = defaultReadChunkSize, consumer: ZipperConsumerClosure) throws -> ZipperCRC32 {
        var checksum = ZipperCRC32(0)
        let localFileHeader = entry.localFileHeader
        fseek(self.archiveFile, entry.dataOffset, SEEK_SET)
        switch entry.type {
        case .file:
            guard let compressionMethod = CompressionMethod(rawValue: localFileHeader.compressionMethod) else {
                throw ArchiveError.invalidCompressionMethod
            }
            switch compressionMethod {
            case .none: checksum = try self.readUncompressed(entry: entry, bufferSize: bufferSize, with: consumer)
            case .deflate: checksum = try self.readCompressed(entry: entry, bufferSize: bufferSize, with: consumer)
            }
        case .directory: try consumer(Data())
        case .symlink:
            let localFileHeader = entry.localFileHeader
            let size = Int(localFileHeader.compressedSize)
            let data = try Data.readChunk(from: self.archiveFile, size: size)
            checksum = data.crc32(checksum: 0)
            try consumer(data)
        }
        return checksum
    }

    // MARK: - Helpers

    private func readUncompressed(entry: Zipper.Entry, bufferSize: UInt32, with consumer: ZipperConsumerClosure) throws -> ZipperCRC32 {
        let size = entry.centralDirectoryStructure.uncompressedSize
        return try Data.consumePart(of: self.archiveFile, size: Int(size),
                                    chunkSize: Int(bufferSize), consumer: consumer)
    }

    private func readCompressed(entry: Zipper.Entry, bufferSize: UInt32, with consumer: ZipperConsumerClosure) throws -> ZipperCRC32 {
        let size = entry.centralDirectoryStructure.compressedSize
        return try Data.decompress(size: Int(size), bufferSize: Int(bufferSize), provider: { (_, chunkSize) -> Data in
            return try Data.readChunk(from: self.archiveFile, size: chunkSize)
        }, consumer: consumer)
    }
}

extension Zipper {
    /// Unzips the contents at the specified source URL to the destination URL.
    ///
    /// - Parameters:
    ///   - destinationURL: The file URL that identifies the destination of the unzip operation.
    /// - Throws: Throws an error if the source item does not exist or the destination URL is not writable.
    public func extract(to destinationURL: URL) throws {
        guard FileManager.default.fileExists(atPath: self.url.path) else {
            throw NSError(domain: NSCocoaErrorDomain,
                          code: CocoaError.fileReadNoSuchFile.rawValue,
                          userInfo: [NSFilePathErrorKey: self.url.path])
        }
        guard self.accessMode == .read else {
            throw Zipper.ArchiveError.unreadableArchive
        }
        // Defer extraction of symlinks until all files & directories have been created.
        // This is necessary because we can't create links to files that haven't been created yet.
        let sortedEntries = self.sorted { (left, right) -> Bool in
            switch (left.type, right.type) {
            case (.directory, .file): return true
            case (.directory, .symlink): return true
            case (.file, .symlink): return true
            default: return false
            }
        }
        for entry in sortedEntries {
            let destinationEntryURL = destinationURL.appendingPathComponent(entry.path)
            _ = try self.extract(entry, to: destinationEntryURL)
        }
    }
    
    /// Unzips the contents at the specified source URL to the destination URL.
    ///
    /// - Parameters:
    ///   - destinationURL: The file URL that identifies the destination of the unzip operation.
    /// - Throws: Throws an error if the source item does not exist or the destination URL is not writable.
    public func unzip(to destinationURL: URL) throws {
        try extract(to: destinationURL)
    }
    
    /// Unzips the contents at the specified source URL to the destination URL.
    ///
    /// - Parameters:
    ///   - destinationURL: The file URL that identifies the destination of the unzip operation.
    /// - Throws: Throws an error if the source item does not exist or the destination URL is not writable.
    public func unarchive(to destinationURL: URL) throws {
        try extract(to: destinationURL)
    }
}

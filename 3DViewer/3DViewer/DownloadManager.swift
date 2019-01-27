//
//  DownloadManager.swift
//  3DViewer
//
//  Created by Eugene Bokhan on 9/14/17.
//  Copyright © 2017 Eugene Bokhan. All rights reserved.
//

import UIKit

// MARK: - Delegate protocol

@objc protocol DownloadManagerDelegate: class {
    @objc optional func didWriteData(bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    @objc optional func didCompleteWithError(error: Error?)
    @objc optional func didFinishDownloadingTo(location: URL)
}

class DownloadManager: NSObject, URLSessionDownloadDelegate {
    
    // MARK: - Delegate property
    
    weak var delegate: DownloadManagerDelegate?
    
    // MARK: - FileDownloader properties
    
    var downloadTask: URLSessionDownloadTask!
    var backgroundSession: URLSession!
    // String describing file name and type
    var fileNameString: String!
    // Remote URL to the source file you want to download
    var remoteURL: URL! {
        didSet {
            fileNameString = remoteURL?.lastPathComponent
        }
    }
    
    // Destination URL to the source file you'll download
    var destinationURLForFile: URL!
    var directoryPath: String! {
        didSet {
            destinationURLForFile = URL(fileURLWithPath: directoryPath.appendingFormat("/\(fileNameString!)"))
        }
    }
    var searchPathForDirectoriesInDomains: [String]! {
        didSet {
            directoryPath = searchPathForDirectoriesInDomains[0]
        }
    }
    
    // MARK: -  Init method
    
    override init() {
        super.init()
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
    }
    
    // MARK: -  Public methods
    
    public func startDownload(fromURL: URL, toDirectory : FileManager.SearchPathDirectory, domainMask: FileManager.SearchPathDomainMask) {
        searchPathForDirectoriesInDomains = NSSearchPathForDirectoriesInDomains(toDirectory, domainMask, true)
        
        // Get the original file name from the original request.
        remoteURL = fromURL
        downloadTask = backgroundSession.downloadTask(with: remoteURL!)
        downloadTask.resume()
    }
    
    public func pauseDownload() {
        if downloadTask != nil{
            downloadTask.suspend()
        }
    }
    
    public func resumeDownload() {
        if downloadTask != nil{
            downloadTask.resume()
        }
    }
    
    public func cancelDownload() {
        if downloadTask != nil{
            downloadTask.cancel()
        }
        // Delete file if it exists
        deleteFile()
    }
    
    // MARK: -  Internal methods
    
    internal func deleteFile() {
        do {
            try FileManager.default.removeItem(at: URL(fileURLWithPath: directoryPath.appendingFormat("/\(fileNameString!)")))
        } catch (let writeError) {
            print("Error removing a file : \(writeError)")
        }
    }
    
    // MARK: - URLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL){
        
        let destinationURLForFile = URL(fileURLWithPath: directoryPath.appendingFormat("/\(fileNameString!)"))
        // Check if the file already exists
        if FileManager.default.fileExists(atPath: destinationURLForFile.path){
            // Call delegate's didFinishDownloading method
            delegate?.didFinishDownloadingTo!(location: destinationURLForFile)
        }
        else{
            do {
                try FileManager.default.moveItem(at: location, to: destinationURLForFile)
                delegate?.didFinishDownloadingTo!(location: destinationURLForFile)
            }catch{
                print("An error occurred while moving file to destination url")
            }
        }
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64){
        print("\(totalBytesWritten) bytes of \(totalBytesExpectedToWrite) are downloaded")
        delegate?.didWriteData!(bytesWritten: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }
    
    // MARK: - URLSessionTaskDelegate
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?){
        downloadTask = nil
        delegate?.didCompleteWithError!(error: error)
        if (error != nil) {
            print(error!.localizedDescription)
        }else{
            print("The task finished transferring data successfully")
        }
    }
    
}


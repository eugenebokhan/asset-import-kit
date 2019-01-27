//
//  DownloadFilesViewController.swift
//  3DViewer
//
//  Created by Eugene Bokhan on 9/14/17.
//  Copyright © 2017 Eugene Bokhan. All rights reserved.
//

import UIKit
import SceneKit

class DownloadFilesViewController: UIViewController, DownloadManagerDelegate {
    
    // MARK: - UI Elements
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var startDownloadButton: UIButton!
    
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBOutlet weak var resumeButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet var progressView: UIProgressView!
    
    // MARK: - Interface Actions
    
    
    @IBAction func browseFilesAction(_ sender: Any) {
        FileBrowser.inARmode = false
        let file = FileBrowser()
        self.present(file, animated: true, completion: nil)
    }
    
    @IBAction func openARAction(_ sender: Any) {
        FileBrowser.inARmode = true
        MBProgressHUD.showAdded(to: self.view, animated: true)
        DispatchQueue.global(qos: .background).async {
            let arViewController = self.storyboard?.instantiateViewController(withIdentifier: "ARViewController") as! ARViewController
            DispatchQueue.main.async {
                self.present(arViewController, animated: true, completion: {
                    MBProgressHUD.hide(for: self.view, animated: true)
                })
            }
        }
    }
    
    @IBAction func startDownloadAction(_ sender: AnyObject) {
        let url = URL(string: pasteboardString)
        downloadManager.startDownload(fromURL: url!, toDirectory: .documentDirectory, domainMask: .userDomainMask)
    }
    @IBAction func pauseAction(_ sender: AnyObject) {
        downloadManager.pauseDownload()
    }
    @IBAction func resumeAction(_ sender: AnyObject) {
        downloadManager.resumeDownload()
    }
    @IBAction func cancelAction(_ sender: AnyObject) {
        downloadManager.cancelDownload()
    }
    
    // MARK: - Properties
    
    let downloadManager = DownloadManager()
    var pasteboardString: String!
    var downloadProgress: Float! {
        willSet {
            activateDownloadButtons()
        }
    }

    // MARK: -  View lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotifications()
        setupUI()
        downloadManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkUIPasteboard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Setup UI methods
    
    func setupUI() {
        progressView.progress = 0
        setupButtons()
        statusLabel.text = "Copy model URL in Safari"
    }
    
    func setupButtons() {
        let enabledColor = #colorLiteral(red: 0.9215686275, green: 0.9254901961, blue: 0.9176470588, alpha: 1)
        let disabledColor = #colorLiteral(red: 0.3294117647, green: 0.3294117647, blue: 0.3294117647, alpha: 1)
        
        startDownloadButton.setTitleColor(enabledColor, for: .normal)
        startDownloadButton.setTitleColor(disabledColor, for: .disabled)
        pauseButton.setTitleColor(enabledColor, for: .normal)
        pauseButton.setTitleColor(disabledColor, for: .disabled)
        resumeButton.setTitleColor(enabledColor, for: .normal)
        resumeButton.setTitleColor(disabledColor, for: .disabled)
        cancelButton.setTitleColor(enabledColor, for: .normal)
        cancelButton.setTitleColor(disabledColor, for: .disabled)
        
        deactivateDownloadButtons()
    }
    
    // MARK: - Setup Notifications
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    // MARK: - Notifications methods
    
    @objc func applicationDidBecomeActive() {
        print("App became active!")
        checkUIPasteboard()
    }
    
    // MARK: - UI Methods
    
    func changeButtonsState() {
        switch statusLabel.text {
        case "URL is copied. Click Download"?:
            activateButtons()
        default:
            deactivateAllButtons()
        }
    }
    
    func activateButtons() {
        startDownloadButton.isEnabled = true
    }
    
    func activateDownloadButtons() {
        cancelButton.isEnabled = true
        resumeButton.isEnabled = true
        pauseButton.isEnabled = true
    }
    
    func deactivateDownloadButtons() {
        cancelButton.isEnabled = false
        resumeButton.isEnabled = false
        pauseButton.isEnabled = false
    }
    
    func deactivateAllButtons() {
        startDownloadButton.isEnabled = false
        pauseButton.isEnabled = false
        resumeButton.isEnabled = false
        cancelButton.isEnabled = false
    }
    
    // MARK: - Check the pasteboard for URL string
    
    func checkUIPasteboard() {
        if let pasteboardString = UIPasteboard.general.string {
            let pathExtension = (pasteboardString as NSString).pathExtension
            if (SCNScene.canImportFileExtension(pathExtension) || pathExtension == "zip" || pathExtension == "scn") {
                statusLabel.text = "URL is copied. Click Download"
                self.pasteboardString = pasteboardString
            } else {
                statusLabel.text = "Copied unsupported URL"
            }
        } else {
            statusLabel.text = "Copy URL in Safari"
        }
        changeButtonsState()
    }
    
    // MARK: - FileDownloaderDelegate
    
    func didWriteData(bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        downloadProgress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
        progressView.setProgress(downloadProgress, animated: true)
    }
    
    func didFinishDownloadingTo(location: URL) {
        deactivateDownloadButtons()
        // Check if the downloaded file is .zip
        if location.pathExtension == "zip" {
           // SSZipArchive.unzipFile(atPath: location.path, toDestination: location.deletingPathExtension().path)
            let archiveURL = URL(fileURLWithPath: location.path)
            let destinationURL = URL(fileURLWithPath: location.deletingPathExtension().path)
            guard let archive = Zipper(url: archiveURL, accessMode: .read) else  { return }
            do {
                try archive.unzip(to: destinationURL)
            } catch _ {}
        }
        browseFilesAction(self)
    }
    
    func didCompleteWithError(error: Error?) {
        progressView.setProgress(0.0, animated: true)
        deactivateDownloadButtons()
    }

}

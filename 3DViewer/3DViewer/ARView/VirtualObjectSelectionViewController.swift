//
//  VirtualObjectSelectionViewController.swift
//  3DViewer
//
//  Created by Eugene Bokhan on 2/1/18.
//  Copyright © 2018 Eugene Bokhan. All rights reserved.
//

import UIKit

class VirtualObjectSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var tableView: UITableView!
    private var size: CGSize!
    private var selectedVirtualObjectRow: Int = -1
    weak var delegate: VirtualObjectSelectionViewControllerDelegate?
    
    init(size: CGSize) {
        super.init(nibName: nil, bundle: nil)
        self.size = size
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView()
        tableView.frame = CGRect(origin: CGPoint.zero, size: self.size)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .light))
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.bounces = false
        
        self.preferredContentSize = self.size
        
        self.view.addSubview(tableView)
        
        // Retrieve the row of the currently selected object
        selectedVirtualObjectRow = UserDefaults.standard.integer(for: .selectedObjectID)
        
        setupNotifications()
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name(rawValue: "Added virtual object"), object: nil)
    }
    
    @objc func handleNotification(_ notification: NSNotification) {
        if notification.name.rawValue == "Added virtual object" {
            tableView.reloadData()
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath)?.textLabel?.text == "Add new object" {
            FileBrowser.inARmode = true
            let fileBrowser = FileBrowser()
                    let screenWidth = UIScreen.main.bounds.width
                    let screenHeight = UIScreen.main.bounds.height
                    let popoverWidth = screenWidth - 80
                    let popoverHeight = screenHeight - 240
            
            fileBrowser.view.frame = CGRect(x: 40, y: 120, width: popoverWidth, height: popoverHeight)
            fileBrowser.modalPresentationStyle = .formSheet
            self.present(fileBrowser, animated: true, completion: nil)
        } else {
            
            // Check if the current row is already selected, then deselect it.
            if indexPath.row == selectedVirtualObjectRow {
                delegate?.virtualObjectSelectionViewControllerDidDeselectObject(self)
            } else {
                delegate?.virtualObjectSelectionViewController(self, didSelectObjectAt: indexPath.row)
                UserDefaults.standard.set(indexPath.row, for: .selectedObjectID)
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VirtualObject.availableObjects.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIsSelected = indexPath.row == selectedVirtualObjectRow
        
        // Create a table view cell.
        let cell = UITableViewCell()
        let label = UILabel(frame: CGRect(x: 53, y: 10, width: 200, height: 30))
        let icon = UIImageView(frame: CGRect(x: 15, y: 10, width: 30, height: 30))
        
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        let vibrancyEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .extraLight))
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.frame = cell.contentView.frame
        cell.contentView.insertSubview(vibrancyView, at: 0)
        vibrancyView.contentView.addSubview(label)
        vibrancyView.contentView.addSubview(icon)
        
        if cellIsSelected {
            cell.accessoryType = .checkmark
        }
        
        if indexPath.row >= VirtualObject.availableObjects.count {
            cell.textLabel?.text = "Add new object"
            cell.imageView?.image = #imageLiteral(resourceName: "addnewnote")
        } else {
            // Fill up the cell with data from the object.
            let object = VirtualObject.availableObjects[indexPath.row]
//            var thumbnailImage = object.thumbImage!
//            if let invertedImage = thumbnailImage.inverted() {
//                thumbnailImage = invertedImage
//            }
            label.text = object.title
            icon.image = object.thumbImage!
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) && tableView.cellForRow(at: indexPath)?.textLabel?.text != "Virtual objects didSet" {
            VirtualObject.availableObjects.remove(at: indexPath.row)
            tableView.reloadSections([indexPath.section], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.clear
    }
}

// MARK: - VirtualObjectSelectionViewControllerDelegate
protocol VirtualObjectSelectionViewControllerDelegate: class {
    func virtualObjectSelectionViewController(_: VirtualObjectSelectionViewController, didSelectObjectAt index: Int)
    func virtualObjectSelectionViewControllerDidDeselectObject(_: VirtualObjectSelectionViewController)
}


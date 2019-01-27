//
//  FileListTableView.swift
//  3DViewer
//
//  Created by Eugene Bokhan on 9/14/17.
//  Copyright © 2017 Eugene Bokhan. All rights reserved.
//

import Foundation
import UIKit

extension FileListViewController {
    
    // MARK: - UITableViewDataSource, UITableViewDelegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive {
            return 1
        }
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return filteredFiles.count
        }
        return sections[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "FileCell"
        var cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        if let reuseCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            cell = reuseCell
        }
        cell.selectionStyle = .gray
        cell.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
        cell.textLabel?.textColor = #colorLiteral(red: 0.3490196078, green: 0.3490196078, blue: 0.3490196078, alpha: 1)
        let selectedFile = fileForIndexPath(indexPath)
        cell.textLabel?.text = selectedFile.displayName
        cell.imageView?.image = selectedFile.type.image()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFile = fileForIndexPath(indexPath)
        searchController.isActive = false
        if selectedFile.isDirectory {
            let fileListViewController = FileListViewController(initialPath: selectedFile.filePath)
            fileListViewController.didSelectFile = didSelectFile
            self.navigationController?.pushViewController(fileListViewController, animated: true)
        }
        else {
            if let didSelectFile = didSelectFile {
                self.dismiss()
                didSelectFile(selectedFile)
            }
            else {
                if FileBrowser.inARmode {
                    if selectedFile.type == .DAE || selectedFile.type == .FBX || selectedFile.type == .OBJ || selectedFile.type == .SCN || selectedFile.type == .MD3 || selectedFile.type == .ZGL || selectedFile.type == .XGL || selectedFile.type == .WRL || selectedFile.type == .STL || selectedFile.type == .SMD || selectedFile.type == .RAW || selectedFile.type == .Q3S || selectedFile.type == .Q3O || selectedFile.type == .PLY || selectedFile.type == .XML || selectedFile.type == .MESH || selectedFile.type == .OFF || selectedFile.type == .NFF || selectedFile.type == .M3SD || selectedFile.type == .MD5ANIM || selectedFile.type == .MD5MESH || selectedFile.type == .MD2 || selectedFile.type == .IRR || selectedFile.type == .IFC || selectedFile.type == .DXF || selectedFile.type == .COB || selectedFile.type == .BVH || selectedFile.type == .B3D || selectedFile.type == .AC {
                        MBProgressHUD.showAdded(to: self.tableView, animated: true)
                        DispatchQueue.global(qos: .background).async {
                            VirtualObject.availableObjects.append(VirtualObject(from: selectedFile))
                            DispatchQueue.main.async {
                                MBProgressHUD.hide(for: self.tableView, animated: true)
                            }
                        }
                    }
                } else {
                    let filePreview = previewManager.previewViewControllerForFile(selectedFile, fromNavigation: true)
                    self.navigationController?.pushViewController(filePreview, animated: true)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive {
            return nil
        }
        if sections[section].count > 0 {
            return collation.sectionTitles[section]
        }
        else {
            return nil
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchController.isActive {
            return nil
        }
        return collation.sectionIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if searchController.isActive {
            return 0
        }
        return collation.section(forSectionIndexTitle: index)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let selectedFile = fileForIndexPath(indexPath)
            selectedFile.delete()
            
            prepareData()
            tableView.reloadSections([indexPath.section], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return allowEditing
    }
    
}


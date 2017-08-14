//
//  FinderSync.swift
//  iCloudExtension
//
//  Created by Robbert Brandsma on 30-06-16.
//  Copyright © 2016 Robbert Brandsma. All rights reserved.
//

import Cocoa
import FinderSync

class FinderSync: FIFinderSync {

    let fm = FileManager.default
    
    // MARK: - Menu and toolbar item support
    
    override var toolbarItemName: String {
        return "iCloud Control"
    }
    
    override var toolbarItemToolTip: String {
        return "Manually manage iCloud storage"
    }
    
    override var toolbarItemImage: NSImage {
        return NSImage(named: "CloudToolbarIcon")!
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        NSLog("menu(for:)")
        let menu = NSMenu(title: "")
        menu.addItem(withTitle: "Remove selected item locally", action: #selector(removeLocal(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Download selected item", action: #selector(downloadItem(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Publish public link", action: #selector(publish(_:)), keyEquivalent: "")
        return menu
    }
    
    @IBAction func removeLocal(_ sender: AnyObject?) {
        NSLog("removeLocal")
        
        for target in currentTargets {
            NSLog("Local removal of \(target) requested")
            do {
                try fm.evictUbiquitousItem(at: target)
                NSLog("Removal of \(target) succeeded")
            } catch {
                NSLog("Removal of \(target) failed with error \(error)")
            }
        }
    }
    
    @IBAction func publish(_ sender: AnyObject?) {
        var urls = [URL]()
        
        for target in currentTargets {
            NSLog("Publishing \(target) requested")
            do {
                let url = try fm.url(forPublishingUbiquitousItemAt: target, expiration: nil)
                NSLog("Publishing \(target) succeeded, url: \(url)")
                urls.append(url)
            } catch {
                NSLog("Publishing \(target) failed with error \(error)")
            }
        }
        
        let pb = NSPasteboard.general()
        pb.clearContents()
        
        pb.writeObjects(urls as [NSPasteboardWriting])
    }
    
    @IBAction func downloadItem(_ sender: AnyObject?) {
        NSLog("Download requested")
        
        for target in currentTargets {
            NSLog("Download of \(target) requested")
            do {
                try fm.startDownloadingUbiquitousItem(at: target)
                NSLog("Download of \(target) succeeded")
            } catch {
                NSLog("Download of \(target) failed with error \(error)")
            }
        }
    }
    
    var currentTargets: [URL] {
        var targets = FIFinderSyncController.default().selectedItemURLs() ?? []
        
        if let targetedUrl = FIFinderSyncController.default().targetedURL(), targets.count == 0 {
            targets.append(targetedUrl)
        }
        
        return targets
    }

}


//
//  ServersSelectionDropDown.swift
//  macOS
//
//  Created by Milen Halachev on 11.11.17.
//  Copyright © 2017 KoCMoHaBTa. All rights reserved.
//

import Foundation
import Cocoa

class ServersSelectionDropDown: NSView {
    
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var serversDropDown: NSPopUpButton! {
        
        didSet {
            
            self.serversDropDown?.removeAllItems()
            self.serversDropDown?.addItems(withTitles: self.servers.map({ $0.name }))
        }
    }
    
    @IBOutlet weak var addServerButton: NSButton!
    
    lazy var servers = [Server].load()
    
    var selectedServer: Server? {
        
        let index = self.serversDropDown.indexOfSelectedItem
        guard index >= 0 else {
            
            return nil
        }
        
        return self.servers[index]
    }
    
    static var `default`: ServersSelectionDropDown {
    
        let nib = NSNib(nibNamed: NSNib.Name(rawValue: "ServersSelectionDropDown"), bundle: nil)
        
        var objects: NSArray?
        nib?.instantiate(withOwner: nil, topLevelObjects: &objects)
        
        return objects?.filter({ $0 is ServersSelectionDropDown }).first as! ServersSelectionDropDown
    }
    
    @IBAction func addServer(_ sender: NSButton) {
        
        let controller = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "AddServerViewController")) as! AddServerViewController
        
        controller.didSaveServer = { server in
            
            [Server].add(server)
            self.servers.append(server)
            self.serversDropDown.addItem(withTitle: server.name)
            self.serversDropDown.selectItem(at: self.serversDropDown.itemTitles.count - 1)
        }
        
        
        let popover = NSPopover()
        popover.contentViewController = controller
        popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .maxX)
    }
}

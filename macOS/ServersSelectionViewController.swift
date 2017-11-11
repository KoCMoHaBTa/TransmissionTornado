//
//  ServersSelectionDropDown.swift
//  macOS
//
//  Created by Milen Halachev on 11.11.17.
//  Copyright © 2017 KoCMoHaBTa. All rights reserved.
//

import Foundation
import Cocoa

class ServersSelectionViewController: NSViewController {
    
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var serversDropDown: NSPopUpButton! {
        
        didSet {
            
            self.serversDropDown?.removeAllItems()
            self.serversDropDown?.addItems(withTitles: self.servers.map({ $0.name }))
        }
    }
    
    @IBOutlet weak var addServerButton: NSButton!
    @IBOutlet weak var selectServerButton: NSButton!
    
    var didSelectServer: ((Server) -> Void)?
    
    lazy var servers = [Server].load()
    
    var selectedServer: Server? {
        
        let index = self.serversDropDown.indexOfSelectedItem
        guard index >= 0 else {
            
            return nil
        }
        
        return self.servers[index]
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if self.didSelectServer == nil {
            
            self.selectServerButton.isHidden = true
        }
    }
    
    override func viewDidAppear() {
        
        super.viewDidAppear()
        
        if self.selectedServer == nil {
            
            self.addServer(self.addServerButton)
        }
    }
    
    @IBAction func addServer(_ sender: Any?) {
        
        let controller = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "AddServerViewController")) as! AddServerViewController
        
        controller.didSaveServer = { server in
            
            [Server].add(server)
            self.servers.append(server)
            self.serversDropDown.addItem(withTitle: server.name)
            self.serversDropDown.selectItem(at: self.serversDropDown.itemTitles.count - 1)
        }
        
        controller.dismissHandler = { controller, response in
            
            controller.dismiss(nil)
            
            if case .cancel = response, self.selectedServer == nil {
                
                self.view.window?.close()
            }
        }
        
        self.presentViewControllerAsSheet(controller)
    }
    
    @IBAction func selectServer(_ sender: Any?) {
        
        guard let server = self.selectedServer else {
            
            self.addServer(sender)
            return
        }
        
        self.didSelectServer?(server)
    }
}

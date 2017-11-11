//
//  ViewController.swift
//  macOS
//
//  Created by Milen Halachev on 6.11.17.
//  Copyright © 2017 KoCMoHaBTa. All rights reserved.
//

import Cocoa
import SafariServices

class ServersViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSUserInterfaceValidations {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var servers: [Server] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedDidAddServer(notification:)), name: .DidAddServer, object: nil)
        
        self.servers = .load()
    }

    override var representedObject: Any? {
        
        didSet {
            
            // Update the view, if already loaded.
        }
    }
    
    //MARK: - Notifications
    
    @objc func receivedDidAddServer(notification: Notification) {
        
        guard let server = notification.userInfo?["server"] as? Server else {
            
            self.servers = .load()
            self.tableView.reloadData()
            return
        }
        
        self.servers.append(server)
        self.tableView.insertRows(at: IndexSet(integer: self.servers.count-1), withAnimation: [.effectFade])
    }
    
    //MARK: - NSTableViewDataSource & NSTableViewDelegate

    func numberOfRows(in tableView: NSTableView) -> Int {
        
        return self.servers.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let server = self.servers[row]
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CellID"), owner: self)
        
        
        if let cell = cell as? NSTableCellView,
        let column = tableColumn,
        let columnIndex = tableView.tableColumns.index(of: column) {
            
            if columnIndex == 0 {
                
                cell.textField?.stringValue = server.name
            }
            
            if columnIndex == 1 {
                
                cell.textField?.stringValue = server.address
            }
            
            if columnIndex == 2 {
                
                cell.textField?.stringValue = server.downloadDir ?? "--"
            }
        }
        
        return cell
    }
    
    //MARK: - Actions
    
    @IBAction func delete(_ sender: Any?) {
        
        let row = self.tableView.selectedRow
        guard row >= 0 else {
            
            return
        }
        
        self.servers.remove(at: row)
        self.servers.save()
        self.tableView.removeRows(at: IndexSet(integer: row), withAnimation: [.effectFade])
        
        let nextRow = row - 1
        if nextRow >= 0 {
            
            self.tableView.selectRowIndexes(IndexSet(integer: nextRow), byExtendingSelection: false)
        }
    }
    
    @IBAction func viewServer(_ sender: Any?) {
        
        let row = self.tableView.selectedRow
        guard row >= 0 else {
            
            return
        }
        
        let server = self.servers[row]
        guard let url = URL(string: server.address) else {
            
            return
        }
        
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func editServer(_ sender: Any?) {
        
        let row = self.tableView.selectedRow
        guard row >= 0 else {
            
            return
        }
        
        let controller = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "AddServerViewController")) as! AddServerViewController
        controller.server = self.servers[row]
        controller.didSaveServer = { server in
            
            self.servers.remove(at: row)
            self.servers.insert(server, at: row)
            self.servers.save()
            
            self.tableView.reloadData()
        }
        
        self.presentViewControllerAsSheet(controller)
    }
    
    //MARK: - NSUserInterfaceValidations
    
    func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        
        if item.action == #selector(viewServer(_:))
        || item.action == #selector(delete(_:))
        || item.action == #selector(editServer(_:)) {
            
            return self.tableView.selectedRow >= 0
        }
        
        return true
    }
}


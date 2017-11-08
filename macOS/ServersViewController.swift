//
//  ViewController.swift
//  macOS
//
//  Created by Milen Halachev on 6.11.17.
//  Copyright © 2017 KoCMoHaBTa. All rights reserved.
//

import Cocoa

class ServersViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
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
}


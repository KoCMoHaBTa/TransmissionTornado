//
//  ServersViewController.swift
//  TransmissionTorrentUploader
//
//  Created by Milen Halachev on 15.10.17.
//  Copyright © 2017 KoCMoHaBTa. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

class ServersViewController: UITableViewController {
    
    var servers: [Server] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.loadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "AddServer", let controller = segue.destination as? AddServerViewController {
            
            controller.didSaveServer = { [unowned self] server -> Void in
                
                self.navigationController?.popToViewController(self, animated: true)
                
                DispatchQueue.main.async {
                    
                    self.servers.insert(server, at: 0)
                    self.servers.save()
                    self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
                    self.tableView.deselectRow(at: IndexPath(row: 0, section: 0), animated: true)
                }
            }
        }
        
        if segue.identifier == "EditServer", let controller = segue.destination as? AddServerViewController, let cell = sender as? UITableViewCell, let indexPath = self.tableView.indexPath(for: cell) {
            
            let server = self.servers[indexPath.row]
            controller.server = server
            
            controller.didSaveServer = { [unowned self] server -> Void in
                
                self.navigationController?.popToViewController(self, animated: true)
                
                DispatchQueue.main.async {
                    
                    self.servers.remove(at: indexPath.row)
                    self.servers.insert(server, at: indexPath.row)
                    self.servers.save()
                    
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    func loadData() {
        
        self.servers = .load()
        self.tableView.reloadData()
    }
    
    //MARK: - UITableViewDataSource & UITableViewDelegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.servers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath)
        cell.textLabel?.text = self.servers[indexPath.row].name
        cell.detailTextLabel?.text = self.servers[indexPath.row].address
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if case .delete = editingStyle {
            
            self.servers.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.servers.save()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let server = self.servers[indexPath.row]
        guard let url = URL(string: server.address) else {
            
            return
        }
        
        let safari = SFSafariViewController(url: url)
        self.present(safari, animated: true, completion: nil)
        
    }
}

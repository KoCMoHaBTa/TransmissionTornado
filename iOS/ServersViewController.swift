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
    
    lazy var didSelectServer: ((Server) -> Void)? = { [unowned self] server in
        
        guard let url = URL(string: server.address), url.scheme?.lowercased() == "http" || url.scheme?.lowercased() == "https" else {
            
            let alert = UIAlertController(title: "Cannot open server.", message: "Scheme is not supported. Only 'http' and 'https' url shceme is supported", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        let safari = SFSafariViewController(url: url)
        self.present(safari, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedDidAddServer(notification:)), name: .DidAddServer, object: nil)
        
        self.loadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "AddServer", let controller = segue.destination as? AddServerViewController {
            
            controller.didSaveServer = { [unowned self] server -> Void in
                
                [Server].add(server)
                self.navigationController?.popToViewController(self, animated: true)
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
    
    //MARK: - Notifications
    
    @objc func receivedDidAddServer(notification: Notification) {
        
        guard let server = notification.userInfo?["server"] as? Server else {
            
            self.servers = .load()
            self.tableView.reloadData()
            return
        }
        
        self.servers.insert(server, at: 0)
        self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
        self.tableView.deselectRow(at: IndexPath(row: 0, section: 0), animated: true)
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
        cell.textLabel?.text = self.servers[indexPath.row].name + " - " + self.servers[indexPath.row].address
        cell.detailTextLabel?.text = self.servers[indexPath.row].downloadDir
        
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
        self.didSelectServer?(server)
    }
}

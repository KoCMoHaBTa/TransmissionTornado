//
//  TorrentsViewController.swift
//  TransmissionTorrentUploader
//
//  Created by Milen Halachev on 15.10.17.
//  Copyright © 2017 KoCMoHaBTa. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

class TorrentsViewController: UITableViewController {
    
    var torrents: [Torrent] = []
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(TorrentsViewController.receivedDidImportTorrentFileNotification(_:)), name: .DidImportTorrentFile, object: nil)
        
        self.loadData()
    }
    
    func loadData() {

        self.torrents = .load()
        self.tableView.reloadData()
    }
    
    @objc func receivedDidImportTorrentFileNotification(_ notification: Notification) {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + (0.5 * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) {
            
            guard let torrent = notification.userInfo?["torrent"] as? Torrent else {
                
                self.loadData()
                return
            }
            
            self.torrents.insert(torrent, at: 0)
            self.tableView?.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            self.tableView?.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
            self.tableView?.deselectRow(at: IndexPath(row: 0, section: 0), animated: true)            
        }
    }
    
    @IBAction func deleteAll() {
        
        self.torrents.forEach { (torrent) in
            
            try? FileManager.default.removeItem(at: torrent.url)
        }
        
        self.loadData()
    }
    
    @IBAction func dismiss() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    private func send(_ torrent: Torrent, to server: Server) {
        
        torrent.send(to: server) { (error) in
            
            if let error = error {
                
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            //show the server
            if let url = URL(string: server.address) {
                
                let safari = SFSafariViewController(url: url)
                self.present(safari, animated: true, completion: nil)
            }
            
            //delete the torrent
            if let index = self.torrents.index(of: torrent) {
                
                self.torrents.remove(at: index)
                try? FileManager.default.removeItem(at: torrent.url)
                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
    }
    
    //MARK: - UITableViewDataSource & UITableViewDelegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.torrents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath)
        cell.textLabel?.text = self.torrents[indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if case .delete = editingStyle {
            
            let torrent = self.torrents.remove(at: indexPath.row)
            try? FileManager.default.removeItem(at: torrent.url)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let torrent = self.torrents[indexPath.row]
        let servers = [Server].load()
        
        if servers.count == 1, let server = servers.first {
            
            self.send(torrent, to: server)
        }
        else {
            
            //pick a server first
            let serversViewController = self.storyboard?.instantiateViewController(withIdentifier: "ServersViewController") as! ServersViewController
            
            serversViewController.navigationItem.title = "Select Server"
            serversViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(TorrentsViewController.dismiss as (TorrentsViewController) -> () -> ()))
            serversViewController.didSelectServer = { [unowned self] server in
                
                self.dismiss(animated: true, completion: {
                    
                    self.send(torrent, to: server)
                })
            }
            
            self.present(UINavigationController(rootViewController: serversViewController), animated: true, completion: nil)
        }
    }
}

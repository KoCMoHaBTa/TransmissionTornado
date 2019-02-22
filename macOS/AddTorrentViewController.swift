//
//  AddTorrentViewController.swift
//  macOS
//
//  Created by Milen Halachev on 22.02.19.
//  Copyright © 2019 KoCMoHaBTa. All rights reserved.
//

import Foundation
import Cocoa

class AddTorrentViewController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var urlTextFiled: NSTextField!
    @IBOutlet weak var addTorrentButton: NSButton!
    
    var url: URL? {
        
        didSet {
            
            self.urlTextFiled.stringValue = self.url?.absoluteString ?? ""
            self.validate()
        }
    }
    
    private var serverSelectionViewController: ServersSelectionViewController {
        
        return self.children.first as! ServersSelectionViewController
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.urlTextFiled.stringValue = self.url?.absoluteString ?? ""
        self.validate()
    }
    
    func validate() {
        
        self.addTorrentButton?.isEnabled = self.url != nil && self.serverSelectionViewController.selectedServer != nil
    }
    
    //MARK: - Actions
    
    @IBAction func browseAction(_ sender: Any?) {
        
        let panel = NSOpenPanel()
        panel.isAccessoryViewDisclosed = true
        panel.allowedFileTypes = ["torrent"]
        
        panel.begin { [weak self] (response) in
            
            if case .OK = response, let url = panel.urls.first {
                
                DispatchQueue.main.async {
                    
                    self?.url = url
                }
            }
        }
    }
    
    @IBAction func addAction(_ sender: Any?) {

        guard let url = self.url else {
            
            self.urlTextFiled.becomeFirstResponder()
            self.validate()
            return
        }
        
        guard let server = self.serverSelectionViewController.selectedServer else {
            
            self.serverSelectionViewController.addServer(sender)
            self.validate()
            return
        }
        
        let torrent = Torrent(url: url)
        torrent.send(to: server, completion: { [weak self] (error) in

            if let error = error {

                DispatchQueue.main.async {

                    NSAlert(error: error).runModal()
                }
                return
            }

            //show the server
            if let url = URL(string: server.address) {

                NSWorkspace.shared.open(url)
                
                DispatchQueue.main.async {
                    
                    self?.view.window?.close()
                }
            }
        })
    }
    
    //MARK: - NSTextFieldDelegate
    
    func controlTextDidChange(_ obj: Notification) {
        
        self.url = URL(string: self.urlTextFiled.stringValue)
    }
}

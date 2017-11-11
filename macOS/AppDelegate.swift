//
//  AppDelegate.swift
//  macOS
//
//  Created by Milen Halachev on 6.11.17.
//  Copyright © 2017 KoCMoHaBTa. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var mainWindow: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        self.mainWindow = NSApplication.shared.mainWindow
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        
        if flag == false {
            
            self.mainWindow?.makeKeyAndOrderFront(self)
        }
        
        return true
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {


        return true
    }
    
    @IBAction func openTorrent(_ sender: Any?) {
        
        let serversDropDown = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "ServersSelectionViewController")) as! ServersSelectionViewController
        let panel = NSOpenPanel()
        panel.accessoryView = serversDropDown.view
        panel.isAccessoryViewDisclosed = true
        panel.allowedFileTypes = ["torrent"]
        
        panel.begin { (response) in
            
            if case .OK = response, let url = panel.urls.first {
                
                DispatchQueue.main.async {
                    
                    guard let server = serversDropDown.selectedServer else {
                        
                        return
                    }
                    
                    let torrent = Torrent(url: url)
                    torrent.send(to: server, completion: { (error) in
                        
                        if let error = error {
                            
                            DispatchQueue.main.async {
                                
                                NSAlert(error: error).runModal()
                            }
                            return
                        }
                        
                        //show the server
                        if let url = URL(string: server.address) {
                            
                            NSWorkspace.shared.open(url)
                        }
                    })
                }
            }
        }
    }
}


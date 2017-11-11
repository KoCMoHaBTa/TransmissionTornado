//
//  AddServerViewController.swift
//  macOS
//
//  Created by Milen Halachev on 8.11.17.
//  Copyright © 2017 KoCMoHaBTa. All rights reserved.
//

import Foundation
import Cocoa

class AddServerViewController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var serverAddressTextField: NSTextField!
    @IBOutlet weak var downloadDirTextField: NSTextField!
    
    var server: Server?
    var didSaveServer: ((Server) -> Void)? = { server in
        
        [Server].add(server)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.nameTextField.stringValue = self.server?.name ?? ""
        self.serverAddressTextField.stringValue = self.server?.address ?? ""
        self.downloadDirTextField.stringValue = self.server?.downloadDir ?? ""
    }
    
    @IBAction func saveAction(_ sender: Any?) {
        
        let name = self.nameTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard name.isEmpty == false else {
            
            self.nameTextField.becomeFirstResponder()
            return
        }
        
        let address = self.serverAddressTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard address.isEmpty == false else {
            
            self.serverAddressTextField.becomeFirstResponder()
            return
        }
        
        var downloadDir: String? = nil
        if self.downloadDirTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            
            downloadDir = self.downloadDirTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        let server = Server(name: name, address: address, downloadDir: downloadDir)
        self.didSaveServer?(server)
        self.view.window?.close()
    }
    
    @IBAction func cancelAction(_ sender: Any?) {
        
        self.view.window?.close()
    }
    
    //MARK: - NSTextFieldDelegate
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        
        if commandSelector == #selector(insertNewline(_:)) {
            
            self.saveAction(control)
            return true
        }
        
        return false
    }
}

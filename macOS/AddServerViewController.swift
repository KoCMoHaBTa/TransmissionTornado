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
    @IBOutlet weak var accountTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    
    var server: Server?
    var didSaveServer: ((Server) -> Void)? = { server in
        
        [Server].add(server)
    }
    
    var dismissHandler: (AddServerViewController, NSApplication.ModalResponse) -> Void = { controller, response in
        
        controller.dismiss(nil)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.nameTextField.stringValue = self.server?.name ?? ""
        self.serverAddressTextField.stringValue = self.server?.address ?? ""
        self.downloadDirTextField.stringValue = self.server?.downloadDir ?? ""
        self.accountTextField.stringValue = self.server?.account ?? ""
        self.passwordTextField.stringValue = self.server?.password ?? ""
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

        var account: String? = nil;
        if self.accountTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            account = self.accountTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        var password: String? = nil;
        if self.passwordTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            password = self.passwordTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        let server = Server(name: name, address: address, downloadDir: downloadDir, account: account, password:password)
        self.didSaveServer?(server)
        self.dismissHandler(self, .OK)
    }
    
    @IBAction func cancelAction(_ sender: Any?) {
        
        self.dismissHandler(self, .cancel)
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

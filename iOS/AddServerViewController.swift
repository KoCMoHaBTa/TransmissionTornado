//
//  AddServerViewController.swift
//  TransmissionTorrentUploader
//
//  Created by Milen Halachev on 15.10.17.
//  Copyright © 2017 KoCMoHaBTa. All rights reserved.
//

import Foundation
import UIKit

class AddServerViewController: UITableViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var serverAddressTextField: UITextField!
    @IBOutlet weak var downloadDirTextField: UITextField!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var server: Server?
    var didSaveServer: ((Server) -> Void)?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.nameTextField.text = self.server?.name
        self.serverAddressTextField.text = self.server?.address
        self.downloadDirTextField.text = self.server?.downloadDir
        self.accountTextField.text = self.server?.credentials?.account
        self.passwordTextField.text = self.server?.credentials?.password
    }
    
    @IBAction func save() {
        
        guard let name = self.nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), name.isEmpty == false else {
            
            self.nameTextField.becomeFirstResponder()
            return
        }
        
        guard let address = self.serverAddressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), address.isEmpty == false else {
            
            self.serverAddressTextField.becomeFirstResponder()
            return
        }
        
        let downloadDir = self.downloadDirTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var account: String? = nil;
        if let value = self.accountTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines), value.isEmpty == false {
            
            account = value
        }
        
        var password: String? = nil;
        if let value = self.passwordTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines), value.isEmpty == false {
            
            password = value
        }
        
        var credentials: Credentials? = nil
        if let account = account, let password = password {
            
            credentials = Credentials(account: account, password: password)
        }
        
        let server = Server(name: name, address: address, downloadDir: downloadDir, credentials: credentials)
        self.didSaveServer?(server)
    }
}

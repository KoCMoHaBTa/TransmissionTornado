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
    
    var server: Server?
    var didSaveServer: ((Server) -> Void)?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.nameTextField.text = self.server?.name
        self.serverAddressTextField.text = self.server?.address
        self.downloadDirTextField.text = self.server?.downloadDir
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
        
        let server = Server(name: name, address: address, downloadDir: downloadDir)
        self.didSaveServer?(server)
    }
}

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
    
    var didAddServer: ((Server) -> Void)?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    @IBAction func add() {
        
        guard let name = self.nameTextField.text else {
            
            self.nameTextField.becomeFirstResponder()
            return
        }
        
        guard let address = self.serverAddressTextField.text else {
            
            self.serverAddressTextField.becomeFirstResponder()
            return
        }
        
        let server = Server(name: name, address: address)
        self.didAddServer?(server)
    }
}

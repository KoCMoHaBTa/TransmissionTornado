//
//  Server.swift
//  TransmissionTorrentUploader
//
//  Created by Milen Halachev on 15.10.17.
//  Copyright © 2017 KoCMoHaBTa. All rights reserved.
//

import Foundation

struct Server: Codable {
    
    let name: String
    let address: String
    let downloadDir: String?
}

extension Array where Element == Server {
    
    static var url: URL {
        
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("servers", isDirectory: false).appendingPathExtension("plist")
    }
    
    static func load() -> [Element] {
        
        guard let data = try? Data(contentsOf: self.url) else {
            
            return []
        }
        
        let result = try? PropertyListDecoder().decode(self, from: data)
        return result ?? []
    }
    
    func save() {
        
        try? PropertyListEncoder().encode(self).write(to: type(of: self).url)
    }
    
    static func add(_ server: Server) {
        
        var servers = self.load()
        servers.append(server)
        servers.save()
        
        NotificationCenter.default.post(name: .DidAddServer, object: nil, userInfo: ["server": server])
    }
}

extension Notification.Name {
    
    static let DidAddServer = Notification.Name("DidAddServer")
}

//
//  Torrent.swift
//  TransmissionTorrentUploader
//
//  Created by Milen Halachev on 15.10.17.
//  Copyright © 2017 KoCMoHaBTa. All rights reserved.
//

import Foundation

struct Torrent {
    
    let url: URL
    
    var name: String {
        
        return self.url.lastPathComponent
    }
}

extension Torrent: Equatable {
    
    static func ==(lhs: Torrent, rhs: Torrent) -> Bool {
        
        return lhs.url == rhs.url
    }
}

extension Torrent {
    
    func send(to server: Server, completion: ((Error?) -> Void)?) {
        
        fatalError("implement this")
    }
}

extension Array where Element == Torrent {
    
    static var directory: URL {
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("torrents", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
        
        return dir
    }
    
    static func load() -> [Element] {
        
        let files = try? FileManager.default.contentsOfDirectory(at: self.directory, includingPropertiesForKeys: [.creationDateKey])
        
        let result = files?.map({ Element(url: $0) })
        return result ?? []
    }
    
    static func importElement(from url: URL) -> Bool {

        do {
            
            let destinationFile = self.directory.appendingPathComponent(url.lastPathComponent, isDirectory: false)
            try FileManager.default.copyItem(at: url, to: destinationFile)

            let torrent = Torrent(url: destinationFile)
            NotificationCenter.default.post(name: .DidImportTorrentFile, object: nil, userInfo: ["torrent": torrent])

            return true
        }
        catch {

            print(error)
            return false
        }
    }
}

extension Notification.Name {
    
    static let DidImportTorrentFile = Notification.Name("DidImportTorrentFile")
}

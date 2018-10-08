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
        
        struct RequestData: Encodable {
            
            let method: String = "torrent-add"
            let arguments: Arguments
            
            struct Arguments: Encodable {
                
                let paused = false
                let downloadDir: String?
                let metainfo: String //base64 encoded .torrent contents
                
                enum CodingKeys: String, CodingKey {
                    
                    case paused
                    case downloadDir = "download-dir"
                    case metainfo
                }
            }
        }
        
        struct ResponseData: Decodable {
            
            let result: String
        }
        
        do {
            
            let data = try Data(contentsOf: self.url)
            let requestData = RequestData(arguments: RequestData.Arguments(downloadDir: server.downloadDir, metainfo: data.base64EncodedString()))
            
            guard let url = URL(string: server.address)?.appendingPathComponent("/transmission/rpc") else {
                
                completion?(NSError(domain: NSURLErrorDomain, code: NSURLErrorUnsupportedURL, userInfo: [NSURLErrorFailingURLStringErrorKey: server.address]))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = try JSONEncoder().encode(requestData)

            if (nil != server.account) {
                var password: String = ""
                if (nil != server.password) {
                    password = server.password!;
                }
                let authStringToEncodeBase64: String = server.account! + ":" + password;
                let authData: Data = authStringToEncodeBase64.data(using: String.Encoding.utf8)!
                request.addValue("Basic " + authData.base64EncodedString(), forHTTPHeaderField: "Authorization")
            }
            
            func performRequest() {
                
                URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                    
                    if let error = error {
                        
                        completion?(error)
                        return
                    }
                    
                    if let response = response as? HTTPURLResponse, response.statusCode == 409, let session = response.allHeaderFields["X-Transmission-Session-Id"] as? String {
                        
                        request.setValue(session, forHTTPHeaderField: "X-Transmission-Session-Id")
                        performRequest()
                        return
                    }
                    
                    guard (response as? HTTPURLResponse)?.statusCode == 200, let data = data else {
                        
                        completion?(NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil))
                        return
                    }
                    
                    do {
                       
                        let responseData = try JSONDecoder().decode(ResponseData.self, from: data)
                        
                        guard responseData.result == "success" else {
                            
                            let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedFailureReasonErrorKey: responseData.result])
                            completion?(error)
                            return
                        }
                        
                        completion?(nil)
                    }
                    catch {
                        
                        completion?(error)
                    }
                    
                }).resume()
            }
            
            performRequest()
        }
        catch {
            
            completion?(error)
        }
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

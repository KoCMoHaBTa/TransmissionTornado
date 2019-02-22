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
        
        if self.url.scheme == "magnet" {
            
            return URLComponents(url: self.url, resolvingAgainstBaseURL: true)?.queryItems?.filter({ $0.name == "dn" }).first?.value?.appending(".magnet") ?? self.url.absoluteString
        }
        
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
                let metainfo: String?   //Either "filename" OR "metainfo" MUST be included.
                let filename: String?   //Either "filename" OR "metainfo" MUST be included.
                
                init(downloadDir: String?, contents: Contents) {
                    
                    self.downloadDir = downloadDir
                    
                    switch contents {
                        
                        case .metainfo(let metainfo):
                            self.metainfo = metainfo
                            self.filename = nil
                        
                        case .url(let url):
                            self.metainfo = nil
                            self.filename = url.absoluteString
                    }
                }
                
                enum Contents {
                    
                    case metainfo(String)   //base64 encoded .torrent contents
                    case url(URL)           //HTTP or magnet URL
                }
                
                enum CodingKeys: String, CodingKey {
                    
                    case paused
                    case downloadDir = "download-dir"
                    case metainfo
                    case filename
                }
            }
        }
        
        struct ResponseData: Decodable {
            
            let result: String
        }
        
        do {
            
            let requestData: RequestData
            
            if self.url.isFileURL {
             
                let data = try Data(contentsOf: self.url)
                requestData = .init(arguments: RequestData.Arguments(downloadDir: server.downloadDir, contents: .metainfo(data.base64EncodedString())))
            }
            else {
                
                requestData = .init(arguments: RequestData.Arguments(downloadDir: server.downloadDir, contents: .url(self.url)))
            }
            
            guard let url = URL(string: server.address)?.appendingPathComponent("/transmission/rpc") else {
                
                completion?(NSError(domain: NSURLErrorDomain, code: NSURLErrorUnsupportedURL, userInfo: [NSURLErrorFailingURLStringErrorKey: server.address]))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = try JSONEncoder().encode(requestData)

            if let credentials = server.credentials {
                
                let authStringToEncodeBase64 = credentials.account + ":" + credentials.password
                if let authData = authStringToEncodeBase64.data(using: .utf8) {
                    
                    request.addValue("Basic " + authData.base64EncodedString(), forHTTPHeaderField: "Authorization")
                }
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
        
        let result: [Element]? = files?.map({ url in
            
            //if the file is magent or url - the contents are the actual link
            if url.pathExtension == "magnet" || url.pathExtension == "url", let string = try? String(contentsOf: url), let url = URL(string: string) {

                return Element(url: url)
            }
            
            return Element(url: url)
        })
        return result ?? []
    }
    
    static func importElement(from url: URL) -> Bool {

        do {
            
            let torrent: Torrent
            
            if url.isFileURL {
                
                let destinationFile = self.directory.appendingPathComponent(url.lastPathComponent, isDirectory: false)
                try FileManager.default.copyItem(at: url, to: destinationFile)
                
                torrent = Torrent(url: destinationFile)
                
            }
            else {
                
                let type = url.scheme ?? "url"
                let destinationFile = self.directory.appendingPathComponent(NSUUID().uuidString, isDirectory: false).appendingPathExtension(type)
                
                try url.absoluteString.write(to: destinationFile, atomically: true, encoding: .utf8)
                torrent = Torrent(url: url)
            }
            
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

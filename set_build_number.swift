#!/usr/bin/swift

import Foundation

//Sets the build number into a given Info.plist using the following format 1.2.3.456 where 456 is the build number. This also work if you have a single number for a build number, eg 567.

let usage = "Sets the build number into a given Info.plist using the following format 1.2.3.456 where 456 is the build number.\nThis also work if you have a single number for a build number, eg 567.\n\nUsage: set_build_number.swift <Info.plist path> <build number>\n"

extension String: Error {}

do {
    
    guard CommandLine.arguments.count == 3 else {
        
        throw usage
    }
    
    let path = CommandLine.arguments[1]
    let buildNumber = CommandLine.arguments[2]
    
    guard let plist = NSMutableDictionary(contentsOfFile: path) else {
    
        throw "Unable to read file.\n"
    }
    
    var build = plist["CFBundleVersion"] as? String
    
    var components = build?.components(separatedBy: ".")
    components?.removeLast()
    components?.append(buildNumber)
    
    build = components?.joined(separator: ".")
    plist["CFBundleVersion"] = build
    
    guard plist.write(toFile: path, atomically: true) else {
        
        throw "Unable to write file.\n"
    }
}
catch {
    
    print(error)
}

//
//  tmdiff - perform a time machine diff on text files
//
//  Created by Erica Sadun on 9/29/16.
//  Copyright © 2016 Erica Sadun. All rights reserved.


import Cocoa
public let manager = FileManager.default

// Fetch arguments and test for usage
var arguments = CommandLine.arguments
let appName = arguments.remove(at: 0).lastPathComponent
func usage() -> Never {
    print("Perform a time machine diff on text files")
    print("Usage: \(appName) --list")
    print("       \(appName) [offset: 1] path")
    exit(-1)
}

// Separate arguments
let options = arguments.filter({ $0.hasPrefix("--") })
arguments = arguments.filter({ !$0.hasPrefix("--") })

// Fetch time machine backup list in reverse order
let tmitems = tmlist()

// Process options
if options.contains("--list") {
    tmitems.enumerated().forEach {
        print("\($0.0): \($0.1.ns.lastPathComponent)")
    }
    exit(0)
}

// Only valid way forward is `path` or `offset path`
guard 1...2 ~= arguments.count else { usage() }

// Fetch core path, and make canonical
let corePath = arguments.last!
var isDir: ObjCBool = false
guard manager.fileExists(atPath: corePath, isDirectory: &isDir),
    !isDir.boolValue,
    let components = manager.componentsToDisplay(forPath: corePath) else
{
    print("Must supply a path to an existing (non-dir) file")
    exit(-1)
}
var path = components.joined(separator: "/")

// Update offset if count parameter was supplied
var offset = 1
if arguments.count == 2, let offsetCount = Int(arguments[0]) {
    offset = offsetCount
}

// Test offset
guard tmitems.count > offset else {
    print("Time machine offset too high (\(offset) vs \(tmitems.count)). Bailing")
    exit(-1)
}

// Retrieve specific backup
let tm_path = (tmitems[offset] as String).appendingPathComponent(path)
path = "/Volumes/" + path

// Diff 'em and get out of Dodge
print(diff(tm_path, path))

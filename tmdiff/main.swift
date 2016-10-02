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
    print("Perform a time machine diff on a text file")
    print("       \(appName) --list (count)")
    print("       \(appName) --help")
    print("       \(appName) (--offset count) path")
    exit(-1)
}

// Help message
if arguments.contains("--help") { usage() }

// Fetch time machine backup list in reverse order
let tmItems = tmlist()

// Perform Time Machine backup list
if arguments.contains("--list") {
    var max = tmItems.count
    if let argOffset = arguments.index(of: "--list"),
        arguments.index(after: argOffset) < arguments.endIndex
    {
        let countString = arguments[arguments.index(after: argOffset)]
        if let count = Int(countString), count < max { max = count }
    }
    tmItems.prefix(upTo: max).enumerated().forEach {
        print("\($0.0): \($0.1.ns.lastPathComponent)")
    }
    exit(0)
}

// Process offset
var offset = 1
if arguments.contains("--offset") {
    var max = tmItems.count
    if let argOffset = arguments.index(of: "--offset"),
        arguments.index(after: argOffset) < arguments.endIndex {
        let countOffset = arguments.index(after: argOffset)
        let countString = arguments[countOffset]
        if let count = Int(countString), count < max { offset = count }
        else { print("Offset invalid or too high (max is \(max - 1))"); exit(-1) }
        [countOffset, argOffset].forEach { arguments.remove(at: $0) }
    } else {
        print("Invalid use of --offset (must be followed by a number)"); exit(-1)
    }
}

// Filter arguments
arguments = arguments.filter({ !$0.hasPrefix("--") })

// Only valid way forward is `path` or `offset path`
guard arguments.count == 1 else {
    print("Missing file argument")
    usage()
}

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

// Retrieve specific backup
let tmPath = (tmItems[offset] as String).appendingPathComponent(path)
path = "/Volumes/" + path

// Diff 'em and get out of Dodge
print("Time Machine: \(tmItems[offset].lastPathComponent)\n")
print(diff(tmPath, path))

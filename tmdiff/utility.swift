import Foundation

// NSString workarounds
extension String {
    public var ns: NSString {
        return self as NSString
    }
    
    public var lastPathComponent: String {
        return self.ns.lastPathComponent
    }
    
    public func appendingPathComponent(_ string: String) -> String {
        return self.ns.appendingPathComponent(string)
    }
}

/// Return a list of time machine backup paths
public func tmlist() -> [String] {
    let task = Process()
    task.launchPath = "/usr/bin/tmutil"
    task.arguments = ["listbackups"]
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    task.waitUntilExit()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    guard let s = String(data: data, encoding: String.Encoding.utf8)
        else { return [] }
    return s
        .components(separatedBy: "\n")
        .filter({ !$0.isEmpty })
        .reversed()
}

/// Perform diffing
public func diff(_ path1: String, _ path2: String) -> String {
    let task = Process()
    task.launchPath = "/usr/bin/diff"
    task.arguments = [path1, path2]
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    task.waitUntilExit()
    
    let data = pipe
        .fileHandleForReading
        .readDataToEndOfFile()
    return String(data: data, encoding: String.Encoding.utf8) ?? "No result"
}


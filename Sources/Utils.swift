import Foundation
import Environment
import Vapor
import Tasks

public func mktemp<T>(_ template: String = NSUUID().uuidString, prefix: String! = nil, body: @noescape(String) throws -> T) rethrows -> T {
    var prefix = prefix ?? Env["TMPDIR"] ?? "/tmp/"
    if !prefix.hasSuffix("/") { prefix += "/" }
    
    let path = prefix + "\(template).XXXXXX"
    
    return try path.withCString { template in
        let mutable = UnsafeMutablePointer<Int8>(template)
        guard let file = mktemp(mutable) else { throw Error.mktempFailed }
        // Remove the file on exit.
        defer { unlink(file) }
        return try body(String(validatingUTF8: file)!)
    }
}

public func swiftpmManifestTurnToJSON(at path: String) throws -> String {
    
    let result = try Task.run(
        "/Library/Developer/Toolchains/swift-DEVELOPMENT-SNAPSHOT-2016-06-06-a.xctoolchain/usr/bin/swift",
        "package",
        "dump-package",
        "--output",
        path
    )
    guard result.code == 0 else {
        throw Error.packageSwiftParsingFailed
    }
    return result.stdout
}

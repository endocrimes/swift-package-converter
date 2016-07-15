import Foundation
import Environment
import Vapor
import Tasks

public func mktemp<T>(prefix: String! = nil, body: @noescape(String) throws -> T) rethrows -> T {
    var prefix = prefix ?? Env["TMPDIR"] ?? "/tmp/"
    if !prefix.hasSuffix("/") { prefix += "/" }

    let path = prefix + "\(String(random())).XXXXXX"
    
    return try path.withCString { template in
        let mutable = UnsafeMutablePointer<Int8>(template)
        guard let file = mktemp(mutable) else { throw Error.mktempFailed }
        // Remove the file on exit.
        defer { unlink(file) }
        return try body(String(validatingUTF8: file)!)
    }
}

public func swiftpmManifestTurnToJSON(at path: String) throws -> String {
    
//    let swiftPath = try Task.run("swiftenv which swift")
//    guard swiftPath.code == 0 else {
//        throw Error.swiftPathLookup
//    }
    
    let result = try Task.run(
        "swift",
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

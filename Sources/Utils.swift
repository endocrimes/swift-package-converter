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
    
    let swiftPath = try Task.run("swiftenv", "which", "swift")
    guard swiftPath.code == 0 else {
        throw Error.swiftPathLookup
    }
    
    let result = try Task.run(
        swiftPath.stdout,
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

public func stringContentsOfFile(at path: String) throws -> String {
    return try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
}

class TimerMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let start = NSDate()
        var response = try next.respond(to: request)
        let duration = -start.timeIntervalSinceNow
        let ms = Double(Int(duration * 1000 * 1000))/1000
        let text = "\(ms) ms"
        response.headers["vapor-duration"] = Response.Headers.Values(text)
        return response
    }
}

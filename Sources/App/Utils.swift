import Foundation
import Environment
import Vapor
import HTTP
import Tasks

public func mkdtemp<T>(prefix: String! = nil, body: (String) throws -> T) rethrows -> T {
    var prefix = prefix
    if prefix == nil { prefix = Env["TMPDIR"] ?? "/tmp/" }
    if !prefix!.hasSuffix("/") {
        prefix! += "/"
    }
    #if os(OSX)
    let randomNum = arc4random()
    #else
    let randomNum = rand()
    #endif
    let path = prefix! + "\(String(randomNum)).XXXXXX"
    
    return try path.withCString { template in
        let mutable = UnsafeMutablePointer<Int8>(template)
        let dir = mkdtemp(mutable)
        if dir == nil { throw AppError.mkdtempFailed }
        defer { rmdir(dir!) }
        return try body(String(validatingUTF8: dir!)!)
    }
}

public func swiftpmManifestTurnToJSON(at path: String) throws -> String {
    
    let result = try Task.run(
        "swift",
        "package",
        "dump-package",
        "--input",
        path
    )
    guard result.code == 0 else {
        throw AppError.packageSwiftParsingFailed(result.stderr)
    }
    return result.stdout
}

public func stringContentsOfFile(at path: String) throws -> String {
    return try String(contentsOfFile: path, encoding: .utf8)
}

class TimerMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let start = NSDate()
        let response = try next.respond(to: request)
        let duration = -start.timeIntervalSinceNow
        let ms = Double(Int(duration * 1000 * 1000))/1000
        let text = "\(ms) ms"
        response.headers["vapor-duration"] = text
        return response
    }
}

class LoggingMiddleware: Middleware {
    
    weak var app: Droplet?
    init(app: Droplet) {
        self.app = app
    }
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let start = NSDate()
        let response = try next.respond(to: request)
        let duration = -start.timeIntervalSinceNow
        let ms = Double(Int(duration * 1000 * 1000))/1000
        let durationText = "\(ms) ms"
        app?.log.info("[\(NSDate())] \(request.method) \(request.uri.path) -> \(response.status.statusCode) (\(durationText))")
        return response
    }
}


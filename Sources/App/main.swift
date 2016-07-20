import Foundation
import Vapor
import Environment

enum Error: ErrorProtocol {
    case noBodySupplied
    case packageSwiftParsingFailed
    case mktempFailed
    case swiftPathLookup
}

// start the server
let app = Application()
app.add(LoggingMiddleware(app: app))
app.add(TimerMiddleware())

// routes
app.get("/") { _ in
    let css = "<style>body { padding: 50px; font: 14px \"Lucida Grande\", Helvetica, Arial, sans-serif; } a {color: #00B7FF;}</style>"
    let body = "<html><head>\(css)</head><body><h1>swiftpm.honza.tech</h1><p>See documentation at <a href=\"https://github.com/czechboy0/swift-package-converter\">github.com/czechboy0/swift-package-converter</p></h1></body></html>"
    return Response(headers: ["Content-Type":"text/html"], body: body)
}

app.get("/swift-version") { _ in
    var comps = #file.characters.split(separator: "/").map(String.init)
    let path = ([""] + comps.dropLast(3) + [".swift-version"]).joined(separator: "/")
    var version = try stringContentsOfFile(at: path)
    if version.characters.last! == "\n" {
        version = String(version.characters.dropLast())
    }
    return Response(headers: ["Content-Type":"text/plain"], body: version)
}

app.post("/to-json") { request in
    
    guard let bytes = request.body.bytes where !bytes.isEmpty else {
        return try Response(status: .badRequest, json: JSON(["error": "No Package.swift data supplied"]))
    }
    
    //create a temp file
    let result = try mktemp { (path) -> String in
        
        //write data to temp file
        let string = try bytes.toString()
        try string.write(toFile: path, atomically: true, encoding: NSUTF8StringEncoding)
        
        //ask swiftpm to parse it
        let result = try swiftpmManifestTurnToJSON(at: path)
        return result
    }
    
    return Response(headers: ["Content-Type":"application/json"], body: result)
}

app.start()

import Foundation
import Vapor
import HTTP
import Environment

enum AppError: Error {
    case noBodySupplied
    case packageSwiftParsingFailed(String)
    case mkdtempFailed
    case swiftPathLookup
}

// start the server
let app = Droplet()
app.middleware.append(LoggingMiddleware(app: app))
app.middleware.append(TimerMiddleware())

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
    
    guard let bytes = request.body.bytes, !bytes.isEmpty else {
        return try Response(status: .badRequest, json: JSON(["error": "No Package.swift data supplied"]))
    }
    
    //create a temp file
    let result = try mkdtemp { (folderPath) -> String in
        
        let path = "\(folderPath)/Package.swift"
        
        //write data to temp file
        let string = try bytes.toString()
        try string.write(toFile: path, atomically: true, encoding: .utf8)
        
        //ask swiftpm to parse it
        let result = try swiftpmManifestTurnToJSON(at: path)
        
        //clean up
        unlink(path)
        
        return result
    }
    
    return Response(headers: ["Content-Type":"application/json"], body: result)
}

app.serve()

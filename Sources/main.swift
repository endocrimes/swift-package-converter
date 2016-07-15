import Foundation
import Vapor
import Environment

enum Error: ErrorProtocol {
    case noBodySupplied
    case packageSwiftParsingFailed
    case mktempFailed
}

// start the server
let app = Application()

// routes
app.get("/") { _ in
    return "See documentation at https://github.com/czechboy0/swift-package-converter"
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

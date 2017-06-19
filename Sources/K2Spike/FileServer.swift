import Foundation
import SwiftServerHttp

/// File serving handler that conforms to FileResponseCreating
public struct FileServer: FileResponseCreating {
    /// Map of supported file extensions to mime types
    static let mimeMap = [
        "css": "text/css",
        "ff2": "font/woff2",
        "html": "text/html",
        "js": "application/javascript",
        "jpg": "image/jpeg",
        "json": "application/json",
        "off": "font/woff2",
        "png": "image/png",
        "svg": "image/svg+xml"
    ]

    let folderPath: String

    public init(folderPath: String) {
        self.folderPath = folderPath
    }

    public func serve(request: HTTPRequest, context: RequestContext, filePath: String, response: HTTPResponseWriter) -> HTTPBodyProcessing {
        let fileURL = URL(fileURLWithPath: folderPath).appendingPathComponent(filePath)

        // Load data from file
        guard let fileData = try? Data(contentsOf:fileURL) else {
            let httpResponse = HTTPResponse(httpVersion: request.httpVersion,
                                        status: .badRequest,
                                        transferEncoding: .chunked,
                                        headers: HTTPHeaders())

            response.writeResponse(httpResponse)
            response.done()

            return .discardBody
        }

        // Default to octet-stream mime type
        var mimeType = "application/octet-stream"

        if let fileType = fileURL.lastPathComponent.components(separatedBy: ".").last {
            mimeType = FileServer.mimeMap[fileType] ?? mimeType
        }

        // Write response and body
        let httpResponse = HTTPResponse(httpVersion: request.httpVersion,
                                        status: .ok,
                                        transferEncoding: .chunked,
                                        headers: HTTPHeaders([("Content-Type", mimeType)]))

        response.writeResponse(httpResponse)
        response.writeBody(data: fileData) { _ in
            response.done()
        }

        return .discardBody
    }
}

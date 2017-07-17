import Foundation
import HTTP

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

        // Check if file exists
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            // Return 404
            response.writeHeader(status: .notFound, headers: [.transferEncoding: "chunked"])
            response.done()

            return .discardBody
        }

        // Check if file is readable
        guard FileManager.default.isReadableFile(atPath: fileURL.path) else {
            // Return 403
            response.writeHeader(status: .forbidden, headers: [.transferEncoding: "chunked"])
            response.done()

            return .discardBody
        }

        // Load data from file
        guard let fileData = try? Data(contentsOf:fileURL) else {
            // Return 500
            response.writeHeader(status: .internalServerError, headers: [.transferEncoding: "chunked"])
            response.done()

            return .discardBody
        }

        // Default to octet-stream mime type
        var mimeType = "application/octet-stream"

        if let fileType = fileURL.lastPathComponent.components(separatedBy: ".").last {
            mimeType = FileServer.mimeMap[fileType] ?? mimeType
        }

        // Write response and body
        response.writeHeader(status: .ok, headers: [.transferEncoding: "chunked",.contentType: mimeType])
        response.writeBody(fileData) { _ in
            response.done()
        }

        return .discardBody
    }
}

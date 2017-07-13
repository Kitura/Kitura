import Foundation

public protocol ResponseObject {
    func toData() -> Data?
}

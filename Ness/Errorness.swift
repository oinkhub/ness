import Foundation

public struct Errorness: LocalizedError {
    public var errorDescription: String? { return string }
    private let string: String
    init(_ string: String) { self.string = string }
}

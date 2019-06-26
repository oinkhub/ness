import Foundation

public final class Desk {
    public var content = "" { didSet { changed = true } }
    private(set) var changed = false
    private var url: URL?
    private let queue = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
    
    public init() { }
    
    public func close(_ new: @escaping(() -> Void), _ done: @escaping(() -> Void)) {
        if changed {
            if let url = self.url {
                
            } else {
                DispatchQueue.main.async { new() }
            }
        } else {
            DispatchQueue.main.async { done() }
        }
    }
}

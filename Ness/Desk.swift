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
    
    public func save(_ name: String, error: @escaping((Error) -> Void), done: @escaping((URL) -> Void)) {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name)
        save(URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name), error: error) {
            done(url)
        }
    }
    
    private func save(_ url: URL, error: @escaping((Error) -> Void), done: @escaping(() -> Void)) {
        queue.async { [weak self] in
            guard let content = self?.content else { return }
            do {
                try Data(content.utf8).write(to: url)
                DispatchQueue.main.async { done() }
            } catch let exception {
                DispatchQueue.main.async { error(exception) }
            }
        }
    }
}

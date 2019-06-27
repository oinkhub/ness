import Foundation

public class Desk {
    public final class New: Desk {
        public override init() {
            super.init()
        }
        
        public override func close(error: @escaping ((Error) -> Void), done: @escaping (() -> Void)) {
            if changed {
                DispatchQueue.main.async { error(Fail("Needs saving")) }
            } else {
                DispatchQueue.main.async { done() }
            }
        }
    }
    
    public final class Loaded: Desk {
        private let url: URL
        
        public init(_ url: URL, error: @escaping((Error) -> Void), done: @escaping(() -> Void)) {
            self.url = url
            super.init()
            queue.async {
                _ = url.startAccessingSecurityScopedResource()
                do {
                    self.content = try String(decoding: Data(contentsOf: url), as: UTF8.self)
                    DispatchQueue.main.async { done() }
                } catch let exception {
                    DispatchQueue.main.async { error(exception) }
                }
            }
        }
        
        public override func close(error: @escaping ((Error) -> Void), done: @escaping (() -> Void)) {
            if changed {
                save(url, error: error) { [weak self] in
                    self?.url.stopAccessingSecurityScopedResource()
                    done()
                }
            } else {
                DispatchQueue.main.async { done() }
            }
        }
    }
    
    public var content = "" { didSet { changed = true } }
    private(set) var changed = false
    private let queue = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
    private init() { }
    public func close(error: @escaping((Error) -> Void), done: @escaping(() -> Void)) { }
    
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

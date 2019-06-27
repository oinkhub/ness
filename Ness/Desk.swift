import Foundation

public class Desk {
    public final class New: Desk {
        public override init() { super.init() }
        
        public override func close(_ save: @escaping((@escaping ((String) -> Void)) -> Void), error: @escaping ((Error) -> Void), done: @escaping (() -> Void)) {
            if changed {
                DispatchQueue.main.async {
                    save { [weak self] in
                        self?.save(URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent($0), error: error, done: done)
                    }
                }
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
        
        public override func close(_ save: @escaping ((@escaping ((String) -> Void)) -> Void), error: @escaping ((Error) -> Void), done: @escaping (() -> Void)) {
            if changed {
                self.save(url, error: error) { [weak self] in
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
    
    public func close(_ save: @escaping((@escaping((String) -> Void)) -> Void), error: @escaping((Error) -> Void), done: @escaping(() -> Void)) { }
    
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

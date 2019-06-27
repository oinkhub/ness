import Foundation

public class Desk {
    public final class New: Desk {
        var url: URL?
        
        public override init() {
            super.init()
            timer.setEventHandler { [weak self] in
                guard let self = self else { return }
                if self.url == nil {
                    self.url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
                }
                self.save(self.url!)
            }
        }
        
        convenience init(_ done: @escaping(() -> Void)) {
            self.init()
            queue.async { [weak self] in
                guard let url = self?.url else { return }
                if let content = try? String(decoding: Data(contentsOf: url), as: UTF8.self) {
                    self?.content = content
                    self?.saveable = true
                }
                DispatchQueue.main.async { done() }
            }
        }
        
        public override func close(_ save: @escaping((@escaping ((String, @escaping((URL) -> Void)) -> Void)) -> Void), error: @escaping ((Error) -> Void), done: @escaping (() -> Void)) {
            timer.schedule(deadline: .distantFuture)
            if saveable {
                DispatchQueue.main.async {
                    save { [weak self] name, result in
                        self?.queue.async {
                            let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name)
                            self?.clean()
                            self?.save(url, error: error) { result(url) }
                        }
                    }
                }
            } else {
                queue.async { [weak self] in
                    self?.clean()
                    DispatchQueue.main.async { done() }
                }
            }
        }
        
        private func clean() {
            if url != nil && FileManager.default.fileExists(atPath: url!.path) {
                try? FileManager.default.removeItem(at: url!)
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
            timer.setEventHandler { [weak self] in
                guard let url = self?.url else { return }
                self?.save(url)
            }
        }
        
        public override func close(_ save: @escaping ((@escaping ((String, @escaping((URL) -> Void)) -> Void)) -> Void), error: @escaping ((Error) -> Void), done: @escaping (() -> Void)) {
            timer.schedule(deadline: .distantFuture)
            if saveable {
                self.save(url, error: error) { [weak self] in
                    self?.url.stopAccessingSecurityScopedResource()
                    done()
                }
            } else {
                DispatchQueue.main.async { done() }
            }
        }
    }
    
    static var timeout = TimeInterval(1)
    public private(set) var content = ""
    var saveable = false
    private let queue = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
    private let timer = DispatchSource.makeTimerSource(queue: .global(qos: .background))
    
    private init() {
        timer.resume()
        timer.schedule(deadline: .distantFuture)
    }
    
    public func update(_ content: String) {
        self.content = content
        saveable = true
        timer.schedule(deadline: .now() + Desk.timeout)
    }

    public func close(_ save: @escaping((@escaping ((String, @escaping((URL) -> Void)) -> Void)) -> Void), error: @escaping((Error) -> Void), done: @escaping(() -> Void)) { }
    
    private final func save(_ url: URL, error: ((Error) -> Void)? = nil, done: (() -> Void)? = nil) {
        queue.async { [weak self] in
            guard let content = self?.content else { return }
            do {
                try Data(content.utf8).write(to: url, options: .atomic)
                DispatchQueue.main.async { done?() }
            } catch let exception {
                DispatchQueue.main.async { error?(exception) }
            }
        }
    }
}

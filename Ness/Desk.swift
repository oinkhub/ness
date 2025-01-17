import Foundation

public class Desk {
    public class func new() -> Desk {
        let desk = Desk(url.appendingPathComponent(UUID().uuidString))
        desk.cached = true
        return desk
    }
    
    public class func cache(_ result: @escaping(([Desk]) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var desks = [Desk]()
            if FileManager.default.fileExists(atPath: url.path) {
                try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil).forEach {
                    let desk = Desk($0)
                    desk.content = try! String(decoding: Data(contentsOf: $0), as: UTF8.self)
                    desk.cached = true
                    desks.append(desk)
                }
            } else { try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true) }
            if desks.isEmpty {
                desks.append(Desk.new())
            }
            DispatchQueue.main.async { result(desks) }
        }
    }
    
    public class func load(_ url: URL, done: @escaping((Desk) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            _ = url.startAccessingSecurityScopedResource()
            let desk = Desk(url)
            desk.content = try! String(decoding: Data(contentsOf: url), as: UTF8.self)
            DispatchQueue.main.async { done(desk) }
        }
    }
    
    static var timeout = TimeInterval(1)
    static let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(".cache")
    public private(set) var content = ""
    public private(set) var cached = false
    public let url: URL
    private let timer = DispatchSource.makeTimerSource(queue: .init(label: "", qos: .background, target: .global(qos: .background)))
    
    fileprivate init(_ url: URL) {
        self.url = url
        timer.resume()
        timer.schedule(deadline: .distantFuture)
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            if !FileManager.default.fileExists(atPath: self.url.deletingLastPathComponent().path) {
                try! FileManager.default.createDirectory(at: self.url.deletingLastPathComponent(), withIntermediateDirectories: true)
            }
            try! Data(self.content.utf8).write(to: self.url, options: .atomic)
        }
    }
    
    deinit { url.stopAccessingSecurityScopedResource() }
    
    public func update(_ content: String) {
        self.content = content
        timer.schedule(deadline: .now() + Desk.timeout)
    }

    public func name(_ name: String, url: @escaping((URL) -> Void)) {
        let temporal = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name)
        save(temporal) { url(temporal) }
    }
    
    public func save(_ url: URL, done: @escaping(() -> Void)) {
        timer.setEventHandler(handler: nil)
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            try? Data(self.content.utf8).write(to: url, options: .atomic)
            if self.cached {
                try? FileManager.default.removeItem(at: self.url)
            }
            DispatchQueue.main.async { done() }
        }
    }
    
    public func discard() {
        timer.setEventHandler(handler: nil)
        let url = self.url
        DispatchQueue.global(qos: .background).async { try? FileManager.default.removeItem(at: url) }
    }
}

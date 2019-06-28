import Foundation

public class Desk {
    public class func new() -> Desk {
        let desk = Desk(url.appendingPathComponent(UUID().uuidString))
        desk.nameable = true
        return desk
    }
    
    public class func cache(_ result: @escaping(([Desk]) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var desks = [Desk]()
            if FileManager.default.fileExists(atPath: url.path) {
                try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil).forEach {
                    let desk = Desk($0)
                    desk.content = try! String(decoding: Data(contentsOf: $0), as: UTF8.self)
                    desk.nameable = true
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
    public private(set) var nameable = false
    let url: URL
    private let timer = DispatchSource.makeTimerSource(queue: .init(label: "", qos: .background, target: .global(qos: .background)))
    
    fileprivate init(_ url: URL) {
        self.url = url
        timer.resume()
        timer.schedule(deadline: .distantFuture)
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            try! Data(self.content.utf8).write(to: self.url, options: .atomic)
        }
    }
    
    deinit { url.stopAccessingSecurityScopedResource() }
    
    public func update(_ content: String) {
        self.content = content
        timer.schedule(deadline: .now() + Desk.timeout)
    }

    public func name(_ name: String, url: @escaping((URL) -> Void)) {
        timer.setEventHandler(handler: nil)
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            let temporal = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name)
            try? Data(self.content.utf8).write(to: temporal, options: .atomic)
            try? FileManager.default.removeItem(at: self.url)
            DispatchQueue.main.async { url(temporal) }
        }
    }
}

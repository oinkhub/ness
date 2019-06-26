import Foundation

final public class Desk {
    public var content = "" { didSet { changed = true } }
    private(set) var changed = false
    private var url: URL?
    private let dispatch = Dispatch()
    
    public init() { }
    
    public func open(_ error: @escaping((Error) -> Void), _ next: @escaping(() -> Void)) {
        dispatch.background({ [weak self] in
            guard let self = self else { return }
            if self.changed && self.url == nil {
                throw Errorness("Page not saved")
            }
        }, error, next)
    }
}

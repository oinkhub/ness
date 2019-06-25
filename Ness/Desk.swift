import Foundation

final public class Desk {
    internal(set) var page = Page()
    private let dispatch = Dispatch()
    
    public init() { }
    
    public func open(_ error: @escaping((Error) -> Void), _ next: @escaping(() -> Void)) {
        dispatch.background({ [weak self] in
            if self?.page.status == .changed {
                throw Errorness("Page not saved")
            }
        }, error, next)
    }
}

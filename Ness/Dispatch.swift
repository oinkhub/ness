import Foundation

final class Dispatch {
    private let queue = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
    
    func background<R>(_ send: @escaping(() throws -> R), _ error: @escaping((Error) -> Void), _ next: @escaping((R) -> Void)) {
        queue.async {
            do {
                let result = try send()
                DispatchQueue.main.async { next(result) }
            } catch let exception {
                DispatchQueue.main.async { error(exception) }
            }
        }
    }
}

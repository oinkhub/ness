import UIKit

public struct Session: Codable {
    public enum Font: Int, Codable {
        case SanFranciscoMono
        case SanFrancisco
    }
    
    public static func load(_ result: @escaping((Session) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            let session = {
                $0 == nil ? Session() : (try? JSONDecoder().decode(Session.self, from: $0!)) ?? Session()
            } (UserDefaults.standard.data(forKey: "session"))
            DispatchQueue.main.async { result(session) }
        }
    }
    
    public var onboard = true { didSet { save() } }
    public var spell = false { didSet { save() } }
    public var numbers = true { didSet { save() } }
    public var line = true { didSet { save() } }
    public var size = CGFloat(16.0) { didSet { save() } }
    public var font = Font.SanFranciscoMono { didSet { save() } }
    public var rating = Calendar.current.date(byAdding: {
        var d = DateComponents()
        d.day = 3
        return d
    } (), to: Date())! { didSet { save() } }
    
    private func save() {
        DispatchQueue.global(qos: .background).async {
            UserDefaults.standard.set(try! JSONEncoder().encode(self), forKey: "session")
        }
    }
}

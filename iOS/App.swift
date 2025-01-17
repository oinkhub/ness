import Ness
import UIKit
import UserNotifications
import StoreKit

private(set) weak var app: App!
@UIApplicationMain final class App: UIViewController, UIApplicationDelegate, UIDocumentPickerDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    var session: Session! { didSet { configure() } }
    private(set) var desk: Desk! { didSet { edit.text.text = desk.content } }
    private(set) weak var edit: Edit!
    private var picked: ((URL) -> Void)!
    
    func application(_: UIApplication, willFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        app = self
        let window = UIWindow()
        window.rootViewController = self
        window.makeKeyAndVisible()
        self.window = window
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().getNotificationSettings {
                if $0.authorizationStatus != .authorized {
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 15) {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
                    }
                }
            }
        }
        
        return true
    }
    
    func application(_: UIApplication, open: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        edit(open)
        return true
    }
    
    @available(iOS 10.0, *) func userNotificationCenter(_: UNUserNotificationCenter, willPresent: UNNotification, withCompletionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        withCompletionHandler([.alert])
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 15) {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [willPresent.request.identifier])
        }
    }
    
    func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt: [URL]) { picked(didPickDocumentsAt.first!) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let edit = Edit()
        self.edit = edit
        view.addSubview(edit)
        
        edit.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        edit.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        edit.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        edit.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        Session.load {
            self.session = $0
            if $0.onboard {
                Onboard()
                self.edit.menu.toggle(self.edit.indicator)
            }
            if Date() >= $0.rating {
                var components = DateComponents()
                components.month = 4
                self.session.rating = Calendar.current.date(byAdding: components, to: Date())!
                if #available(iOS 10.3, *) { SKStoreReviewController.requestReview() }
            }
        }
        
        if desk == nil { create() }
    }
    
    func alert(_ title: String, message: String) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings {
                if $0.authorizationStatus == .authorized {
                    UNUserNotificationCenter.current().add({
                        $0.title = title
                        $0.body = message
                        return UNNotificationRequest(identifier: UUID().uuidString, content: $0, trigger: nil)
                    } (UNMutableNotificationContent()))
                } else {
                    DispatchQueue.main.async { Alert(title, message: message) }
                }
            }
        } else {
            DispatchQueue.main.async { Alert(title, message: message) }
        }
    }
    
    @objc func new() {
        close {
            self.create()
            self.edit.text.becomeFirstResponder()
        }
    }
    
    @objc func open() {
        close {
            let picker = UIDocumentPickerViewController(documentTypes: ["public.content", "public.data"], in: .open)
            picker.popoverPresentationController?.sourceView = self.view
            picker.delegate = self
            self.present(picker, animated: true)
            self.picked = { self.edit($0) }
        }
    }
    
    @objc func settings() { Settings() }
    
    private func edit(_ url: URL) {
        Desk.load(url) {
            self.desk = $0
            self.edit.menu.title.text = url.lastPathComponent
        }
    }
    
    private func create() {
        Desk.cache {
            self.desk = $0.first
            self.edit.menu.title.text = .key("App.new")
        }
    }
    
    private func close(_ then: @escaping(() -> Void)) {
        window!.endEditing(true)
        if desk.cached && !desk.content.isEmpty {
            Name(discard: {
                self.desk.discard()
                then()
            }) {
                self.desk.name($0) {
                    let picker = UIDocumentPickerViewController(url: $0, in: .exportToService)
                    picker.popoverPresentationController?.sourceView = self.view
                    picker.delegate = self
                    self.present(picker, animated: true)
                    self.picked = {
                        self.alert(.key("Alert.new"), message: $0.lastPathComponent)
                        then()
                    }
                }
            }
        } else {
            then()
        }
    }
    
    private func configure() {
        if session.spell {
            edit.text.autocorrectionType = .yes
            edit.text.spellCheckingType = .yes
            edit.text.autocapitalizationType = .sentences
        } else {
            edit.text.autocorrectionType = .no
            edit.text.spellCheckingType = .no
            edit.text.autocapitalizationType = .none
        }
        edit.text.font = {
            switch $0 {
            case .SanFranciscoMono: return .light($1)
            case .SanFrancisco: return .systemFont(ofSize: $1, weight: .light)
            }
        } (session.font, CGFloat(session.size))
        edit.line.isHidden = !session.line
        edit.ruler.isHidden = !session.numbers
        edit.ruler.setNeedsDisplay()
    }
}

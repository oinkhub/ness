import Ness
import UIKit
import UserNotifications

private(set) weak var app: App!
@UIApplicationMain final class App: UIViewController, UIApplicationDelegate, UIDocumentPickerDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    private var picked: ((URL) -> Void)!
    private(set) var desk: Desk! { didSet { edit.text.text = desk.content } }
    private weak var edit: Edit!
    
    func application(_: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        app = self
        let window = UIWindow()
        window.rootViewController = self
        window.makeKeyAndVisible()
        self.window = window
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().getNotificationSettings {
                if $0.authorizationStatus != .authorized {
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 5) {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
                    }
                }
            }
        }
        
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
        view.addSubview(edit)
        self.edit = edit
        
        edit.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        edit.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        edit.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        edit.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        Desk.cache { self.desk = $0.first }
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
            self.desk = Desk.new()
            self.edit.text.becomeFirstResponder()
            self.edit.menu.title.text = .key("App.new")
        }
    }
    
    @objc func open() {
        close {
            let picker = UIDocumentPickerViewController(documentTypes: ["public.content", "public.data"], in: .open)
            picker.popoverPresentationController?.sourceView = self.view
            picker.delegate = self
            self.present(picker, animated: true)
            self.picked = { url in
                Desk.load(url) {
                    self.desk = $0
                    self.edit.menu.title.text = url.lastPathComponent
                }
            }
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
}

import Ness
import UIKit
import UserNotifications

private(set) weak var app: App!
@UIApplicationMain final class App: UIViewController, UIApplicationDelegate, UIDocumentPickerDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    private(set) var desk = Desk() { didSet { edit.text.text = desk.content } }
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
    
    func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt: [URL]) {
        print(didPickDocumentsAt)
        desk = Desk()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let edit = Edit()
        view.addSubview(edit)
        self.edit = edit
        
        edit.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        edit.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        edit.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        edit.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
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
    
    func open() {
        let picker = UIDocumentPickerViewController(url: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("myFile.txt"), in: .exportToService)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @objc func new() {
        window!.endEditing(true)
        desk.close({ self.name() }) { self.open() }
    }
    
    private func name() {
        Name(discard: { self.open() }) {
            self.desk.save($0.isEmpty ? .key("App.untitled") : $0, error: {
                self.alert(.key("Error.save"), message: $0.localizedDescription)
            }) {
                let picker = UIDocumentPickerViewController(url: $0, in: .exportToService)
                picker.delegate = self
                self.present(picker, animated: true)
            }
        }
    }
}

import UIKit

private(set) weak var app: App!

@UIApplicationMain final class App: UIViewController, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        app = self
        let window = UIWindow()
        window.rootViewController = self
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let edit = Edit()
        view.addSubview(edit)
        
        edit.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        edit.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        edit.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        edit.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    @objc func browse() {
        let picker = UIDocumentPickerViewController(documentTypes: [], in: .open)
        present(picker, animated: true, completion: nil)
    }
    
    @objc func new() {
        
    }
}

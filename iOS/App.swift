import Ness
import UIKit

private(set) weak var app: App!
@UIApplicationMain final class App: UIViewController, UIApplicationDelegate, UIDocumentPickerDelegate {
    var window: UIWindow?
    private(set) var desk = Desk()
    private weak var edit: Edit!
    
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
    
    @objc func open() {
        
    }
    
    @objc func new() {
        window!.endEditing(true)
        desk.close({ self.name() }) { self.open() }
    }
    
    private func name() {
        Name({  }) { _ in
            
        }
        /*
        let picker = UIDocumentPickerViewController(url: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("myFile.txt"), in: .exportToService)
        picker.delegate = self
        present(picker, animated: true, completion: nil)*/
    }
}

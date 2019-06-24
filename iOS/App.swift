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
    
    func browse() {
        
    }
}

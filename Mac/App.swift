import Ness
import AppKit
import StoreKit
import UserNotifications

private(set) weak var app: App!
@NSApplicationMain final class App: NSApplication, NSApplicationDelegate, UNUserNotificationCenterDelegate, NSTouchBarDelegate {
    var session: Session! { didSet { configure() } }
    
    required init?(coder: NSCoder) { return nil }
    override init() {
        super.init()
        app = self
        delegate = self
        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool { return true }
    
    @available(OSX 10.14, *) func userNotificationCenter(_: UNUserNotificationCenter, willPresent:
        UNNotification, withCompletionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        withCompletionHandler([.alert])
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 15) {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [willPresent.request.identifier])
        }
    }
    
    @available(OSX 10.12.2, *) override func makeTouchBar() -> NSTouchBar? {
        let bar = NSTouchBar()
        bar.delegate = self
        bar.defaultItemIdentifiers = [.init("new"), .init("open"), .init("save")]
        return bar
    }
    
    @available(OSX 10.12.2, *) func touchBar(_: NSTouchBar, makeItemForIdentifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        let item = NSCustomTouchBarItem(identifier: makeItemForIdentifier)
        let button = NSButton(title: "", target: nil, action: nil)
        item.view = button
        button.title = .key("Touch.\(makeItemForIdentifier.rawValue)")
        button.target = self
        switch makeItemForIdentifier.rawValue {
        case "new": button.action = #selector(new)
        case "open": button.action = #selector(open)
        case "save": button.action = #selector(save)
        default: break
        }
        return item
    }
    
    func applicationDidFinishLaunching(_: Notification) {        
        let menu = NSMenu()
        menu.addItem({
            $0.submenu = NSMenu(title: .key("Menu.git"))
            $0.submenu!.items = [
                NSMenuItem(title: .key("Menu.about"), action: #selector(about), keyEquivalent: ""),
                NSMenuItem.separator(),
                NSMenuItem(title: .key("Menu.preferences"), action: #selector(settings), keyEquivalent: ","),
                NSMenuItem.separator(),
                NSMenuItem(title: .key("Menu.hide"), action: #selector(hide(_:)), keyEquivalent: "h"),
                { $0.keyEquivalentModifierMask = [.option, .command]
                    return $0
                } (NSMenuItem(title: .key("Menu.hideOthers"), action: #selector(hideOtherApplications(_:)), keyEquivalent: "h")),
                NSMenuItem(title: .key("Menu.showAll"), action: #selector(unhideAllApplications(_:)), keyEquivalent: ","),
                NSMenuItem.separator(),
                NSMenuItem(title: .key("Menu.quit"), action: #selector(terminate(_:)), keyEquivalent: "q")]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: "")))
        
        menu.addItem({
            $0.submenu = NSMenu(title: .key("Menu.file"))
            $0.submenu!.items = [
                NSMenuItem(title: .key("Menu.new"), action: #selector(new), keyEquivalent: "n"),
                NSMenuItem(title: .key("Menu.open"), action: #selector(open), keyEquivalent: "o"),
                NSMenuItem.separator(),
                NSMenuItem(title: .key("Menu.save"), action: #selector(save), keyEquivalent: "s"),
                NSMenuItem(title: .key("Menu.close"), action: #selector(NSWindow.close), keyEquivalent: "w")]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: "")))
        
        menu.addItem({
            $0.submenu = NSMenu(title: .key("Menu.edit"))
            $0.submenu!.items = [
                { $0.keyEquivalentModifierMask = [.option, .command]
                    $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.undo"), action: Selector(("undo:")), keyEquivalent: "z")),
                { $0.keyEquivalentModifierMask = [.command, .shift]
                    return $0
                } (NSMenuItem(title: .key("Menu.redo"), action: Selector(("redo:")), keyEquivalent: "z")),
                NSMenuItem.separator(),
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.cut"), action: #selector(NSText.cut(_:)), keyEquivalent: "x")),
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.copy"), action: #selector(NSText.copy(_:)), keyEquivalent: "c")),
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.paste"), action: #selector(NSText.paste(_:)), keyEquivalent: "v")),
                NSMenuItem(title: .key("Menu.delete"), action: #selector(NSText.delete(_:)), keyEquivalent: ""),
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.selectAll"), action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"))]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: "")))
        
        menu.addItem({
            $0.submenu = NSMenu(title: .key("Menu.window"))
            $0.submenu!.items = [
                NSMenuItem(title: .key("Menu.minimize"), action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m"),
                NSMenuItem(title: .key("Menu.zoom"), action: #selector(NSWindow.performZoom(_:)), keyEquivalent: "p"),
                NSMenuItem.separator(),
                NSMenuItem(title: .key("Menu.bringAllToFront"), action: #selector(arrangeInFront(_:)), keyEquivalent: "")]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: "")))
        
        menu.addItem({
            $0.submenu = NSMenu(title: .key("Menu.help"))
            $0.submenu!.items = [NSMenuItem(title: .key("Menu.showHelp"), action: #selector(help), keyEquivalent: "/")]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: "")))
        
        mainMenu = menu
        
        Session.load {
            self.session = $0
            if $0.onboard {
//                Onboard()
            }
            if Date() >= $0.rating {
                var components = DateComponents()
                components.month = 4
                self.session.rating = Calendar.current.date(byAdding: components, to: Date())!
                if #available(OSX 10.14, *) { SKStoreReviewController.requestReview() }
            }
        }
        
        Desk.cache {
            $0.forEach {
                Edit($0)
            }
        }
        
        if #available(OSX 10.14, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().getNotificationSettings {
                if $0.authorizationStatus != .authorized {
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 15) {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
                    }
                }
            }
        }
    }
    
    func alert(_ title: String, message: String) {
        if #available(OSX 10.14, *) {
            UNUserNotificationCenter.current().getNotificationSettings {
                if $0.authorizationStatus == .authorized {
                    UNUserNotificationCenter.current().add({
                        $0.title = title
                        $0.body = message
                        return UNNotificationRequest(identifier: UUID().uuidString, content: $0, trigger: nil)
                    } (UNMutableNotificationContent()))
                } else {
                    DispatchQueue.main.async { Alert(title, message: message).makeKeyAndOrderFront(nil) }
                }
            }
        } else {
            DispatchQueue.main.async { Alert(title, message: message).makeKeyAndOrderFront(nil) }
        }
    }
    
    private func configure() { }
    
    @objc private func new() { Edit(Desk.new()) }
    
    @objc private func open() {
        let browse = NSOpenPanel()
        browse.begin { [weak browse] in
            guard $0 == .OK, let url = browse?.url else { return }
            Desk.load(url) { Edit($0) }
        }
    }
    
    @objc private func save() { }
    @objc private func about() { }
    @objc private func settings() { }
    @objc private func help() { }
}

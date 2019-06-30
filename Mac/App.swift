import Ness
import AppKit
import StoreKit
import UserNotifications

private(set) weak var app: App!
@NSApplicationMain final class App: NSApplication, NSApplicationDelegate, UNUserNotificationCenterDelegate, NSTouchBarDelegate {
    required init?(coder: NSCoder) { return nil }
    override init() {
        super.init()
        app = self
        delegate = self
        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool { return true }
    
    func applicationDidFinishLaunching(_: Notification) {
        let edit = Edit()
        edit.makeKeyAndOrderFront(nil)
        
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
                NSMenuItem(title: .key("Menu.minimize"), action: #selector(Window.performMiniaturize(_:)), keyEquivalent: "m"),
                NSMenuItem(title: .key("Menu.zoom"), action: #selector(Window.performZoom(_:)), keyEquivalent: "p"),
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
        
        /*Hub.session.load {
            self.load()
            self.rate()
        }
        */
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
    
    @objc private func about() { }
    @objc private func settings() { }
    @objc private func help() { }
}

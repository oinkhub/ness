import AppKit

extension NSFont {
    final class func light(_ size: CGFloat) -> NSFont { return NSFont(name: "SFMono-Light", size: size)! }
    final class func bold(_ size: CGFloat) -> NSFont { return NSFont(name: "SFMono-Bold", size: size)! }
}

extension NSColor {
    static let halo = #colorLiteral(red: 0.231372549, green: 0.7215686275, blue: 1, alpha: 1)
}

final class Label: NSTextField {
    override var acceptsFirstResponder: Bool { return false }
    
    init(_ string: String = "") {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        isBezeled = false
        isEditable = false
        isSelectable = false
        stringValue = string
    }
    
    required init?(coder: NSCoder) { return nil }
}

class Window: NSWindow {
    override init(contentRect: NSRect, styleMask: NSWindow.StyleMask, backing: NSWindow.BackingStoreType, defer d: Bool) {
        super.init(contentRect: contentRect, styleMask: styleMask, backing: backing, defer: d)
    }
    
    init(_ width: CGFloat, _ height: CGFloat, style: NSWindow.StyleMask = []) {
        super.init(contentRect: NSRect(x: (NSScreen.main!.frame.width - width) / 2, y: (NSScreen.main!.frame.height - height) / 2, width: width, height: height), styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar, .miniaturizable, style], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        minSize = NSSize(width: 100, height: 80)
        isReleasedWhenClosed = false
        toolbar = NSToolbar(identifier: "")
        toolbar!.showsBaselineSeparator = false
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 13:
            if with.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command {
                close()
            } else {
                super.keyDown(with: with)
            }
        default: super.keyDown(with: with)
        }
    }
}

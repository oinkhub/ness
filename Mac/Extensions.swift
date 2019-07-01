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
    
    required init?(coder: NSCoder) { return nil }
    init(_ string: String = "") {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        isBezeled = false
        isEditable = false
        isSelectable = false
        stringValue = string
    }
}

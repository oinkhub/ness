import AppKit

final class Help: NSWindow {
    @discardableResult init() {
        super.init(contentRect: .init(x: NSScreen.main!.frame.midX - 150, y: NSScreen.main!.frame.midY - 70, width: 300, height: 140), styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar, .miniaturizable], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        toolbar = NSToolbar(identifier: "")
        toolbar!.showsBaselineSeparator = false
        
        let label = Label(.key("Help.label"))
        label.textColor = .init(white: 1, alpha: 0.8)
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        contentView!.addSubview(label)

        label.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 60).isActive = true
        label.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 20).isActive = true
        label.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -20).isActive = true
    }
}

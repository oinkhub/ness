import AppKit

final class About: NSWindow {
    @discardableResult init() {
        super.init(contentRect: .init(x: NSScreen.main!.frame.midX - 150, y: NSScreen.main!.frame.midY - 125, width: 300, height: 250), styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar, .miniaturizable], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        toolbar = NSToolbar(identifier: "")
        toolbar!.showsBaselineSeparator = false
        
        let image = NSImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.imageScaling = .scaleNone
        image.image = NSImage(named: "logo")
        contentView!.addSubview(image)
        
        let label = Label(.key("About.label"))
        label.textColor = .halo
        label.font = .bold(20)
        contentView!.addSubview(label)
        
        let version = Label((Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "")
        version.textColor = .halo
        version.font = .light(12)
        contentView!.addSubview(version)
        
        image.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 80).isActive = true
        image.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        
        label.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: contentView!.centerYAnchor, constant: 20).isActive = true
        
        version.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        version.topAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
    }
}

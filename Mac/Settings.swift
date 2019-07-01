import Ness
import AppKit

final class Settings: NSWindow  {
    private weak var desk: Desk!
    
    @discardableResult init(_ desk: Desk) {
        self.desk = desk
        super.init(contentRect: NSRect(x: 0, y: 0, width: 200, height: 200), styleMask: [.fullSizeContentView, .unifiedTitleAndToolbar, .titled], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        
        let background = NSView()
        background.translatesAutoresizingMaskIntoConstraints = false
        background.wantsLayer = true
        background.layer!.backgroundColor = NSColor.halo.withAlphaComponent(0.4).cgColor
        contentView!.addSubview(background)
        
        background.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        background.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        background.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        background.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        
        app.runModal(for: self)
    }
    /*
    @objc private func save() {
        let save = NSSavePanel()
        save.message = .local("Export.qr")
        save.allowedFileTypes = ["png"]
        save.nameFieldStringValue = List.shared.selected.board.name
        save.begin { [weak self] result in
            if result == .OK {
                self?.saveTo(save.url!)
            }
        }
    }*/
}

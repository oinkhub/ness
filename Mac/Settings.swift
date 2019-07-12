import Ness
import AppKit

final class Settings: NSWindow {
    private final class Check: NSView {
        private(set) weak var label: Label!
        private(set) weak var button: Button.Check!
        
        required init?(coder: NSCoder) { return nil }
        init() {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let border = NSView()
            border.translatesAutoresizingMaskIntoConstraints = false
            border.wantsLayer = true
            border.layer!.backgroundColor = NSColor.halo.withAlphaComponent(0.3).cgColor
            addSubview(border)
            
            let label = Label()
            label.textColor = .white
            label.font = .systemFont(ofSize: 14, weight: .regular)
            addSubview(label)
            self.label = label
            
            let button = Button.Check(nil, action: nil)
            button.on = NSImage(named: "checkOn")
            button.off = NSImage(named: "checkOff")
            addSubview(button)
            self.button = button
            
            heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            button.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            button.topAnchor.constraint(equalTo: topAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            button.widthAnchor.constraint(equalToConstant: 44).isActive = true
            
            border.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
            border.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
            border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        }
    }
    
    private weak var size: Label!
    private weak var mono: Button.Layer!
    private weak var regular: Button.Layer!
    
    init() {
        super.init(contentRect: .init(x: NSScreen.main!.frame.midX - 200, y: NSScreen.main!.frame.midY - 145, width: 400, height: 290), styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar, .miniaturizable], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        toolbar = NSToolbar(identifier: "")
        toolbar!.showsBaselineSeparator = false
        
        let spell = Check()
        spell.label.stringValue = .key("Settings.spell")
        spell.button.checked = app.session.spell
        spell.button.target = self
        spell.button.action = #selector(self.spell(_:))
        
        let numbers = Check()
        numbers.label.stringValue = .key("Settings.numbers")
        numbers.button.checked = app.session.numbers
        numbers.button.target = self
        numbers.button.action = #selector(self.numbers(_:))
        
        let line = Check()
        line.label.stringValue = .key("Settings.line")
        line.button.checked = app.session.line
        line.button.target = self
        line.button.action = #selector(self.line(_:))
        
        let font = Label()
        font.textColor = .white
        font.font = .systemFont(ofSize: 14, weight: .regular)
        font.stringValue = .key("Settings.font")
        contentView!.addSubview(font)
        
        let size = Label()
        size.textColor = .white
        size.font = .systemFont(ofSize: 14, weight: .bold)
        size.stringValue = "\(Int(app.session.size))"
        contentView!.addSubview(size)
        self.size = size
        
        let mono = Button.Layer(self, action: #selector(font(_:)))
        mono.label.stringValue = .key("Settings.mono")
        mono.label.textColor = .black
        mono.label.font = .systemFont(ofSize: 12, weight: .medium)
        mono.width.constant = 100
        contentView!.addSubview(mono)
        self.mono = mono
        
        let regular = Button.Layer(self, action: #selector(font(_:)))
        regular.label.stringValue = .key("Settings.regular")
        regular.label.textColor = .black
        regular.label.font = .systemFont(ofSize: 12, weight: .medium)
        regular.width.constant = 100
        contentView!.addSubview(regular)
        self.regular = regular
        
        let slider = NSSlider()
        slider.target = self
        slider.action = #selector(slider(_:))
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minValue = 6
        slider.maxValue = 70
        slider.integerValue = Int(app.session.size)
        contentView!.addSubview(slider)
        
        var origin = contentView!.topAnchor
        [spell, numbers, line].enumerated().forEach {
            contentView!.addSubview($0.1)
            $0.1.topAnchor.constraint(equalTo: origin, constant: $0.0 == 0 ? 36 : 0).isActive = true
            $0.1.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
            $0.1.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
            origin = $0.1.bottomAnchor
        }
        
        font.topAnchor.constraint(equalTo: origin, constant: 30).isActive = true
        font.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 10).isActive = true
        
        size.centerYAnchor.constraint(equalTo: mono.centerYAnchor).isActive = true
        size.rightAnchor.constraint(equalTo: mono.leftAnchor, constant: -10).isActive = true
        
        mono.centerYAnchor.constraint(equalTo: font.centerYAnchor).isActive = true
        mono.rightAnchor.constraint(equalTo: regular.leftAnchor, constant: -4).isActive = true
        
        regular.centerYAnchor.constraint(equalTo: font.centerYAnchor).isActive = true
        regular.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -12).isActive = true
        
        slider.topAnchor.constraint(equalTo: font.bottomAnchor, constant: 30).isActive = true
        slider.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 12).isActive = true
        slider.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -12).isActive = true
        
        switch app.session.font {
        case .SanFranciscoMono:
            mono.layer!.backgroundColor = NSColor.halo.cgColor
            regular.layer!.backgroundColor = NSColor(white: 1, alpha: 0.4).cgColor
        case .SanFrancisco:
            regular.layer!.backgroundColor = NSColor.halo.cgColor
            mono.layer!.backgroundColor = NSColor(white: 1, alpha: 0.4).cgColor
        }

        makeKeyAndOrderFront(nil)
    }
    
    @objc private func spell(_ button: Button.Check) { app.session.spell = button.checked }
    @objc private func numbers(_ button: Button.Check) { app.session.numbers = button.checked }
    @objc private func line(_ button: Button.Check) { app.session.line = button.checked }
    
    @objc private func font(_ button: Button) {
        if button === mono {
            mono.layer!.backgroundColor = NSColor.halo.cgColor
            regular.layer!.backgroundColor = NSColor(white: 1, alpha: 0.4).cgColor
            app.session.font = .SanFranciscoMono
        } else {
            regular.layer!.backgroundColor = NSColor.halo.cgColor
            mono.layer!.backgroundColor = NSColor(white: 1, alpha: 0.4).cgColor
            app.session.font = .SanFrancisco
        }
    }
    
    @objc private func slider(_ slider: NSSlider) {
        size.stringValue = "\(Int(slider.integerValue))"
        DispatchQueue.main.async { app.session.size = round(slider.doubleValue) }
    }
}

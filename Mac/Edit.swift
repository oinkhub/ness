import Ness
import AppKit

final class Edit: Window  {
    private final class Layout: NSLayoutManager, NSLayoutManagerDelegate {
        private let padding = CGFloat(8)
        
        func layoutManager(_: NSLayoutManager, shouldSetLineFragmentRect: UnsafeMutablePointer<NSRect>,
                           lineFragmentUsedRect: UnsafeMutablePointer<NSRect>, baselineOffset: UnsafeMutablePointer<CGFloat>,
                           in: NSTextContainer, forGlyphRange: NSRange) -> Bool {
            baselineOffset.pointee = baselineOffset.pointee + padding
            shouldSetLineFragmentRect.pointee.size.height += padding + padding
            lineFragmentUsedRect.pointee.size.height += padding + padding
            return true
        }
        
        override func setExtraLineFragmentRect(_ rect: NSRect, usedRect: NSRect, textContainer: NSTextContainer) {
            var rect = rect
            var used = usedRect
            rect.size.height += padding + padding
            used.size.height += padding + padding
            super.setExtraLineFragmentRect(rect, usedRect: used, textContainer: textContainer)
        }
    }
    
    private final class Text: NSTextView {
        private weak var height: NSLayoutConstraint!
        
        init() {
            let storage = NSTextStorage()
            super.init(frame: .zero, textContainer: {
                $1.delegate = $1
                storage.addLayoutManager($1)
                $1.addTextContainer($0)
                $0.lineBreakMode = .byCharWrapping
                return $0
            } (NSTextContainer(), Layout()) )
            translatesAutoresizingMaskIntoConstraints = false
            allowsUndo = true
            drawsBackground = false
            isRichText = false
            insertionPointColor = .halo
            isContinuousSpellCheckingEnabled = true
            font = .light(18)
            textColor = .white
            textContainerInset = NSSize(width: 10, height: 20)
            height = heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
            height.isActive = true
            if #available(OSX 10.12.2, *) {
                isAutomaticTextCompletionEnabled = false
            }
        }
        
        required init?(coder: NSCoder) { return nil }
        
        override func resize(withOldSuperviewSize: NSSize) {
            super.resize(withOldSuperviewSize: withOldSuperviewSize)
            adjust()
        }
        
        override func drawInsertionPoint(in rect: NSRect, color: NSColor, turnedOn: Bool) {
            var rect = rect
            rect.size.width += 3
            super.drawInsertionPoint(in: rect, color: color, turnedOn: turnedOn)
        }
        
        override func didChangeText() {
            super.didChangeText()
            adjust()
        }
        
        override func viewDidEndLiveResize() {
            super.viewDidEndLiveResize()
            DispatchQueue.main.async { [weak self] in self?.adjust() }
        }
        
        private func adjust() {
            textContainer!.size.width = superview!.superview!.frame.width - (textContainerInset.width * 2)
            layoutManager!.ensureLayout(for: textContainer!)
            height.constant = layoutManager!.usedRect(for: textContainer!).size.height + (textContainerInset.height * 2)
        }
        
        override func keyDown(with: NSEvent) {
            switch with.keyCode {
            case 13:
                if with.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command {
                    window!.close()
                } else {
                    super.keyDown(with: with)
                }
            case 53: window!.makeFirstResponder(nil)
            default: super.keyDown(with: with)
            }
        }
    }
    
    init() {
        super.init(600, 400, style: [.resizable])
        
        let text = Text()
        
        let scroll = NSScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.drawsBackground = false
        scroll.hasVerticalScroller = true
        scroll.horizontalScrollElasticity = .none
        scroll.verticalScrollElasticity = .allowed
        scroll.documentView = text
        contentView!.addSubview(scroll)
        
        let title = NSView()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.wantsLayer = true
        title.layer!.backgroundColor = NSColor.halo.cgColor
        title.layer!.cornerRadius = 4
        if #available(OSX 10.13, *) {
            title.layer!.maskedCorners = CACornerMask(arrayLiteral: .layerMaxXMinYCorner, .layerMinXMinYCorner)
        }
        contentView!.addSubview(title)
        
        let name = Label()
        name.textColor = .black
        name.font = .systemFont(ofSize: 12, weight: .bold)
        name.stringValue = .key("App.new")
        contentView!.addSubview(name)
        
        scroll.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 30).isActive = true
        scroll.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -2).isActive = true
        scroll.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 2).isActive = true
        scroll.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -2).isActive = true
        
        text.widthAnchor.constraint(equalTo: scroll.widthAnchor).isActive = true
        text.heightAnchor.constraint(greaterThanOrEqualTo: scroll.heightAnchor).isActive = true
        
        name.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 4).isActive = true
        name.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        
        title.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 1).isActive = true
        title.bottomAnchor.constraint(equalTo: name.bottomAnchor, constant: 6).isActive = true
        title.leftAnchor.constraint(equalTo: name.leftAnchor, constant: -8).isActive = true
        title.rightAnchor.constraint(equalTo: name.rightAnchor, constant: 8).isActive = true
    }
}

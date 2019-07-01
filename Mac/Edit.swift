import Ness
import AppKit

final class Edit: NSWindow  {
    fileprivate final class Layout: NSLayoutManager, NSLayoutManagerDelegate {
        fileprivate let padding = CGFloat(8)
        
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
    
    final class Ruler: NSRulerView {
        fileprivate weak var text: Text!
        fileprivate weak var layout: Layout!
        
        required init(coder: NSCoder) { super.init(coder: coder) }
        init() {
            super.init(scrollView: nil, orientation: .verticalRuler)
            ruleThickness = 40
        }
        
        override func draw(_: NSRect) {
            var numbers = [(Int, CGFloat, CGFloat)]()
            let range = layout.glyphRange(forBoundingRect: text.visibleRect, in: text.textContainer!)
            var i = (try! NSRegularExpression(pattern: "\n")).numberOfMatches(in: text.string,
                                                                              range: NSMakeRange(0, range.location))
            
            var c = range.lowerBound
            while c < range.upperBound {
                i += 1
                let end = layout.glyphRange(forCharacterRange: NSRange(location: text.string.lineRange(for:
                    Range(NSRange(location: c, length: 0), in: text.string)!).upperBound.utf16Offset(in: text.string), length: 0),
                                            actualCharacterRange: nil).upperBound
                
                numbers.append((i, layout.lineFragmentRect(forGlyphAt: c, effectiveRange: nil, withoutAdditionalLayout: true).midY,
                                app.keyWindow!.firstResponder !== text ? 0 : { ($0.lowerBound < end && $0.upperBound > c) || $0.upperBound == c || (layout.extraLineFragmentTextContainer == nil && $0.upperBound == end && end == range.upperBound) ? 0.5 : 0 } (text.selectedRange())))
                c = end
            }
            if layout.extraLineFragmentTextContainer != nil {
                numbers.append((i + 1, layout.extraLineFragmentRect.midY,
                                text.selectedRange().lowerBound == c && app.keyWindow!.firstResponder === text ? 0.7 : 0.4))
            }
            let y = convert(NSZeroPoint, from: text).y + text.textContainerInset.height - layout.padding - 4
            numbers.map({ (NSAttributedString(string: String($0.0), attributes:
                [.foregroundColor: NSColor.halo.withAlphaComponent(0.5 + $0.2), .font: NSFont.light(12)]), $0.1) })
                .forEach { $0.0.draw(at: CGPoint(x: ruleThickness - $0.0.size().width, y: $0.1 + y)) }
        }
        /*
        override func draw(_ rect: CGRect) {
            UIGraphicsGetCurrentContext()!.clear(rect)
            var numbers = [(Int, CGFloat, CGFloat)]()
            let range = layout.glyphRange(for: text.textContainer)
            var i = 0
            var c = range.lowerBound
            while c < range.upperBound {
                i += 1
                let end = layout.glyphRange(forCharacterRange: NSRange(location: text.text.lineRange(for:
                    Range(NSRange(location: c, length: 0), in: text.text)!).upperBound.utf16Offset(in: text.text), length: 0), actualCharacterRange: nil).upperBound
                numbers.append((i, layout.lineFragmentRect(forGlyphAt: c, effectiveRange: nil, withoutAdditionalLayout: true).midY,
                                !text.isFirstResponder ? 0 : {
                                    ($0.lowerBound < end && $0.upperBound > c) ||
                                        $0.upperBound == c ||
                                        (layout.extraLineFragmentTextContainer == nil && $0.upperBound == end && end == range.upperBound) ? 0.6 : 0
                                    } (text.selectedRange)))
                c = end
            }
            if layout.extraLineFragmentTextContainer != nil {
                numbers.append((i + 1, layout.extraLineFragmentRect.midY, text.isFirstResponder && text.selectedRange.lowerBound == c ? 0.6 : 0))
            }
            let y = text.textContainerInset.top + layout.padding - 12
            numbers.map({ (NSAttributedString(string: String($0.0), attributes:
                [.foregroundColor: UIColor.halo.withAlphaComponent(0.4 + $0.2), .font: UIFont.light(14)]), $0.1) })
                .forEach { $0.0.draw(at: CGPoint(x: thickness - $0.0.size().width, y: $0.1 + y)) }
        }
        */
        override func drawHashMarksAndLabels(in: NSRect) { }
    }

    
    final class Text: NSTextView, NSTextViewDelegate {
        fileprivate(set) weak var ruler: Ruler!
        fileprivate let desk: Desk
        private weak var height: NSLayoutConstraint!
        
        init(_ desk: Desk) {
            self.desk = desk
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
            isContinuousSpellCheckingEnabled = false
            font = .light(18)
            string = desk.content
            textColor = .white
            textContainerInset = NSSize(width: 10, height: 40)
            height = heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
            height.isActive = true
            delegate = self
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
            desk.update(string)
            adjust()
        }
        
        override func viewDidEndLiveResize() {
            super.viewDidEndLiveResize()
            adjust()
        }
        
        func textViewDidChangeSelection(_: Notification) {
            DispatchQueue.main.async { self.ruler!.setNeedsDisplay(self.bounds) }
        }
        
        private func adjust() {
            textContainer!.size.width = superview!.superview!.frame.width - (textContainerInset.width * 2) - 40
            layoutManager!.ensureLayout(for: textContainer!)
            height.constant = layoutManager!.usedRect(for: textContainer!).size.height + (textContainerInset.height * 2)
        }
        
        override func keyDown(with: NSEvent) {
            switch with.keyCode {
            case 53: window!.makeFirstResponder(nil)
            default: super.keyDown(with: with)
            }
        }
    }
    
    private(set) weak var text: Text!
    
    @discardableResult init(_ desk: Desk) {
        super.init(contentRect: NSRect(origin: {
            app.windows.isEmpty ? CGPoint(x: NSScreen.main!.frame.midX - 300, y: NSScreen.main!.frame.midY - 200) : {
                CGPoint(x: $0.minX + 32, y: $0.minY - 32)
                } (app.windows.max(by: { $0.frame.minX < $1.frame.minX })!.frame)
        } (), size: CGSize(width: 600, height: 400)),
                   styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar, .miniaturizable, .resizable], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        minSize = NSSize(width: 100, height: 80)
        isReleasedWhenClosed = false
        toolbar = NSToolbar(identifier: "")
        toolbar!.showsBaselineSeparator = false
        
        let ruler = Ruler()
        let text = Text(desk)
        ruler.text = text
        ruler.layout = text.layoutManager as? Layout
        text.ruler = ruler
        self.text = text
        let scroll = NSScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.drawsBackground = false
        scroll.hasVerticalScroller = true
        scroll.horizontalScrollElasticity = .none
        scroll.verticalScrollElasticity = .allowed
        scroll.documentView = text
        scroll.verticalRulerView = ruler
        scroll.rulersVisible = true
        contentView!.addSubview(scroll)
        
        let title = NSView()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.wantsLayer = true
        title.layer!.backgroundColor = NSColor.halo.cgColor
        title.layer!.cornerRadius = 4
        title.layer!.borderColor = .black
        title.layer!.borderWidth = 1
        if #available(OSX 10.13, *) {
            title.layer!.maskedCorners = CACornerMask(arrayLiteral: .layerMaxXMinYCorner, .layerMinXMinYCorner)
        }
        contentView!.addSubview(title)
        
        let name = Label()
        name.textColor = .black
        name.font = .systemFont(ofSize: 12, weight: .bold)
        name.stringValue = desk.cached ? .key("App.new") : desk.url.lastPathComponent
        contentView!.addSubview(name)
        
        scroll.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 2).isActive = true
        scroll.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -2).isActive = true
        scroll.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 2).isActive = true
        scroll.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -2).isActive = true
        
        scroll.documentView!.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -40).isActive = true
        scroll.documentView!.heightAnchor.constraint(greaterThanOrEqualTo: scroll.heightAnchor).isActive = true
        
        name.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 4).isActive = true
        name.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        
        title.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        title.bottomAnchor.constraint(equalTo: name.bottomAnchor, constant: 6).isActive = true
        title.leftAnchor.constraint(equalTo: name.leftAnchor, constant: -8).isActive = true
        title.rightAnchor.constraint(equalTo: name.rightAnchor, constant: 8).isActive = true
        
        var left = contentView!.leftAnchor
        (0 ..< 3).forEach {
            let shadow = NSView()
            shadow.translatesAutoresizingMaskIntoConstraints = false
            shadow.wantsLayer = true
            shadow.layer!.backgroundColor = NSColor(white: 0, alpha: 0.7).cgColor
            shadow.layer!.cornerRadius = 8
            contentView!.addSubview(shadow)
            
            shadow.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 11).isActive = true
            shadow.leftAnchor.constraint(equalTo: left, constant: $0 == 0 ? 11 : 4).isActive = true
            shadow.widthAnchor.constraint(equalToConstant: 16).isActive = true
            shadow.heightAnchor.constraint(equalToConstant: 16).isActive = true
            left = shadow.rightAnchor
        }
        
        makeKeyAndOrderFront(nil)
    }
    
    override func close() {
        if text.desk.cached {
            save()
        } else {
            super.close()
        }
    }
    
    @objc func save() {
        let save = NSSavePanel()
        save.nameFieldStringValue = .key("Name.untitled")
        if text.desk.cached {
            let discard = NSButton(frame: .init(x: 0, y: 0, width: 100, height: 40))
            discard.title = .key("Name.discard")
            discard.bezelStyle = .rounded
            discard.target = self
            discard.action = #selector(self.discard)
            save.accessoryView = discard
        }
        save.showsTagField = false
        save.beginSheetModal(for: self) { [weak self] result in if result == .OK { self?.save(save.url!) } }
    }
    
    private func save(_ url: URL) {
        text.desk.save(url) {
            app.alert(.key("Alert.new"), message: url.lastPathComponent)
        }
        super.close()
    }
    
    @objc private func discard() {
        text.desk.discard()
        sheets.first!.close()
        super.close()
    }
}

import UIKit

final class Edit: UIView, UITextViewDelegate {
    final class Menu: UIView {
        fileprivate(set) weak var title: UILabel!
        fileprivate weak var bottom: NSLayoutConstraint! { didSet { bottom.isActive = true } }
        private weak var height: NSLayoutConstraint!
        
        required init?(coder: NSCoder) { return nil }
        init() {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            clipsToBounds = true
            
            let border = UIView()
            border.translatesAutoresizingMaskIntoConstraints = false
            border.backgroundColor = .halo
            addSubview(border)
            
            let new = UIButton()
            new.addTarget(app, action: #selector(app.new), for: .touchUpInside)
            new.setImage(UIImage(named: "new"), for: .normal)
            
            let open = UIButton()
            open.addTarget(app, action: #selector(app.open), for: .touchUpInside)
            open.setImage(UIImage(named: "open"), for: .normal)
            
            let settings = UIButton()
            settings.addTarget(app, action: #selector(app.settings), for: .touchUpInside)
            settings.setImage(UIImage(named: "settings"), for: .normal)
            
            height = heightAnchor.constraint(equalToConstant: 0)
            height.isActive = true
            
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
            border.topAnchor.constraint(equalTo: topAnchor).isActive = true
            border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            
            var right = rightAnchor
            [settings, open, new].enumerated().forEach {
                $0.1.translatesAutoresizingMaskIntoConstraints = false
                $0.1.imageView!.contentMode = .center
                $0.1.imageView!.clipsToBounds = true
                addSubview($0.1)
                
                $0.1.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
                $0.1.rightAnchor.constraint(equalTo: right, constant: $0.0 == 0 ? -10 : 0).isActive = true
                $0.1.widthAnchor.constraint(equalToConstant: 70).isActive = true
                $0.1.heightAnchor.constraint(equalToConstant: 60).isActive = true
                right = $0.1.leftAnchor
            }
        }
        
        @objc func toggle(_ button: UIButton) {
            button.isSelected.toggle()
            height.constant = button.isSelected ? 60 : 0
            UIView.animate(withDuration: 0.4) {
                self.superview!.layoutIfNeeded()
                self.title.alpha = button.isSelected ? 1 : 0
            }
        }
    }
    
    fileprivate final class Layout: NSLayoutManager, NSLayoutManagerDelegate {
        let padding = CGFloat(4)
        
        required init?(coder: NSCoder) { return nil }
        override init() {
            super.init()
            delegate = self
        }

        func layoutManager(_: NSLayoutManager, shouldSetLineFragmentRect: UnsafeMutablePointer<CGRect>,
                           lineFragmentUsedRect: UnsafeMutablePointer<CGRect>, baselineOffset: UnsafeMutablePointer<CGFloat>,
                           in: NSTextContainer, forGlyphRange: NSRange) -> Bool {
            baselineOffset.pointee = baselineOffset.pointee + padding
            shouldSetLineFragmentRect.pointee.size.height += padding + padding
            lineFragmentUsedRect.pointee.size.height += padding + padding
            return true
        }
        
        override func setExtraLineFragmentRect(_ rect: CGRect, usedRect: CGRect, textContainer: NSTextContainer) {
            var rect = rect
            var used = usedRect
            rect.size.height += padding + padding
            used.size.height += padding + padding
            super.setExtraLineFragmentRect(rect, usedRect: used, textContainer: textContainer)
        }
    }
    
    final class Ruler: UIView {
        fileprivate let thickness = CGFloat(32)
        fileprivate weak var text: Text!
        fileprivate weak var layout: Layout!
        
        required init?(coder: NSCoder) { return nil }
        init() {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            isUserInteractionEnabled = false
            backgroundColor = .clear
            widthAnchor.constraint(equalToConstant: thickness).isActive = true
        }
        
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
    }

    final class Text: UITextView {
        private weak var height: NSLayoutConstraint!
        fileprivate weak var lineTop: NSLayoutConstraint!
        fileprivate weak var lineHeight: NSLayoutConstraint!
        
        required init?(coder: NSCoder) { return nil }
        init() {
            let storage = NSTextStorage()
            super.init(frame: .zero, textContainer: {
                storage.addLayoutManager($1)
                $1.addTextContainer($0)
                return $0
            } (NSTextContainer(), Layout()))
            translatesAutoresizingMaskIntoConstraints = false
            backgroundColor = .clear
            bounces = false
            isScrollEnabled = false
            textColor = .white
            tintColor = .halo
            font = .light(16)
            keyboardType = .alphabet
            keyboardAppearance = .dark
            autocorrectionType = .no
            spellCheckingType = .no
            autocapitalizationType = .none
            contentInset = .zero
            textContainerInset = .init(top: 16, left: 36, bottom: 45, right: 16)
        }
        
        override func caretRect(for position: UITextPosition) -> CGRect {
            var rect = super.caretRect(for: position)
            rect.size.width += 2
            lineTop.constant = rect.origin.y != .infinity ? rect.origin.y : lineTop.constant
            lineHeight.constant = rect.height
            return rect
        }
    }
    
    private(set) weak var text: Text!
    private(set) weak var ruler: Ruler!
    private(set) weak var line: UIView!
    private(set) weak var menu: Menu!
    private(set) weak var indicator: UIButton!
    
    required init?(coder: NSCoder) { return nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        scroll.keyboardDismissMode = .interactive
        scroll.indicatorStyle = .white
        addSubview(scroll)
        
        let line = UIView()
        line.isUserInteractionEnabled = false
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor.halo.withAlphaComponent(0.2)
        line.alpha = 0
        scroll.addSubview(line)
        self.line = line
        
        let text = Text()
        text.delegate = self
        text.inputAccessoryView = UIInputView(frame: .init(x: 0, y: 0, width: 0, height: 42), inputViewStyle: .keyboard)
        scroll.addSubview(text)
        self.text = text
        
        let ruler = Ruler()
        ruler.text = text
        ruler.layout = text.layoutManager as? Layout
        text.addSubview(ruler)
        self.ruler = ruler
        
        let menu = Menu()
        addSubview(menu)
        self.menu = menu
        
        let indicator = UIButton()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.setImage(UIImage(named: "indicator"), for: .normal)
        indicator.setImage(UIImage(named: "down"), for: .selected)
        indicator.imageView!.clipsToBounds = true
        indicator.imageView!.contentMode = .center
        indicator.addTarget(menu, action: #selector(menu.toggle(_:)), for: .touchUpInside)
        addSubview(indicator)
        self.indicator = indicator
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .systemFont(ofSize: 14, weight: .bold)
        title.textColor = .halo
        title.text = .key("App.new")
        title.alpha = 0
        addSubview(title)
        menu.title = title
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: menu.topAnchor).isActive = true
        
        text.topAnchor.constraint(equalTo: scroll.topAnchor).isActive = true
        text.leftAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
        text.rightAnchor.constraint(equalTo: scroll.rightAnchor).isActive = true
        text.widthAnchor.constraint(equalTo: scroll.widthAnchor).isActive = true
        text.bottomAnchor.constraint(greaterThanOrEqualTo: scroll.bottomAnchor).isActive = true
        text.heightAnchor.constraint(greaterThanOrEqualTo: scroll.heightAnchor).isActive = true
        
        ruler.heightAnchor.constraint(greaterThanOrEqualToConstant: max(app.view.frame.height, app.view.frame.width)).isActive = true
        ruler.heightAnchor.constraint(greaterThanOrEqualTo: text.heightAnchor).isActive = true
        ruler.leftAnchor.constraint(equalTo: text.leftAnchor).isActive = true
        ruler.topAnchor.constraint(equalTo: scroll.topAnchor).isActive = true
        
        line.leftAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
        line.rightAnchor.constraint(equalTo: scroll.rightAnchor).isActive = true
        text.lineTop = line.topAnchor.constraint(equalTo: scroll.topAnchor)
        text.lineTop.isActive = true
        text.lineHeight = line.heightAnchor.constraint(equalToConstant: 0)
        text.lineHeight.isActive = true
        
        menu.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        menu.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        if #available(iOS 11.0, *) {
            menu.bottom = menu.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        } else {
            menu.bottom = menu.bottomAnchor.constraint(equalTo: bottomAnchor)
        }
        
        indicator.widthAnchor.constraint(equalToConstant: 70).isActive = true
        indicator.heightAnchor.constraint(equalToConstant: 70).isActive = true
        indicator.bottomAnchor.constraint(equalTo: menu.topAnchor).isActive = true
        indicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        title.bottomAnchor.constraint(equalTo: menu.topAnchor, constant: -4).isActive = true
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        
        ["#", "-", "_", "*", "+"].enumerated().forEach {
            let button = UIButton()
            button.addTarget(self, action: #selector(input(_:)), for: .touchUpInside)
            button.setTitle($0.1, for: [])
            button.setTitleColor(.halo, for: .normal)
            button.backgroundColor = UIColor.halo.withAlphaComponent(0.1)
            button.layer.cornerRadius = 3
            button.titleLabel!.font = .systemFont(ofSize: 20, weight: .regular)
            button.translatesAutoresizingMaskIntoConstraints = false
            text.inputAccessoryView!.addSubview(button)
            
            button.leftAnchor.constraint(equalTo: text.inputAccessoryView!.centerXAnchor, constant: CGFloat(-162 + ($0.0 * 66))).isActive = true
            button.topAnchor.constraint(equalTo: text.inputAccessoryView!.topAnchor, constant: 6).isActive = true
            button.bottomAnchor.constraint(equalTo: text.inputAccessoryView!.bottomAnchor, constant: -4).isActive = true
            button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) {
            self.menu.bottom.constant = {
                if $0.minY < self.frame.height {
                    if #available(iOS 11.0, *) {
                        return -($0.height - self.safeAreaInsets.bottom)
                    } else {
                        return -$0.height
                    }
                } else {
                    return 0
                }
            } (($0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue)
            UIView.animate(withDuration: ($0.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue) {
             self.layoutIfNeeded() }
        }
    }
    
    func textViewDidChange(_: UITextView) {
        app.desk.update(text.text)
        ruler.setNeedsDisplay()
    }
    
    func textViewDidBeginEditing(_: UITextView) {
        line.alpha = 1
        ruler.setNeedsDisplay()
    }
    
    func textViewDidEndEditing(_: UITextView) {
        line.alpha = 0
        ruler.setNeedsDisplay()
    }
    
    func textViewDidChangeSelection(_: UITextView) { ruler.setNeedsDisplay() }
    @objc private func input(_ button: UIButton) { text.insertText(button.title(for: [])!) }
}

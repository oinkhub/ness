import UIKit

final class Edit: UIView, UITextViewDelegate {
    private final class Menu: UIView {
        weak var bottom: NSLayoutConstraint! { didSet { bottom.isActive = true } }
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
            
            height = heightAnchor.constraint(equalToConstant: 0)
            height.isActive = true
            
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
            border.topAnchor.constraint(equalTo: topAnchor).isActive = true
            border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            
            var left = leftAnchor
            [new, open].enumerated().forEach {
                $0.1.translatesAutoresizingMaskIntoConstraints = false
                $0.1.imageView!.contentMode = .center
                $0.1.imageView!.clipsToBounds = true
                addSubview($0.1)
                
                $0.1.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
                $0.1.leftAnchor.constraint(equalTo: left, constant: $0.0 == 0 ? 15 : 0).isActive = true
                $0.1.widthAnchor.constraint(equalToConstant: 70).isActive = true
                $0.1.heightAnchor.constraint(equalToConstant: 60).isActive = true
                left = $0.1.rightAnchor
            }
        }
        
        @objc func toggle(_ button: UIButton) {
            button.isSelected.toggle()
            height.constant = button.isSelected ? 100 : 0
            UIView.animate(withDuration: 0.4) { self.superview!.layoutIfNeeded() }
        }
    }
    
    private final class Layout: NSLayoutManager, NSLayoutManagerDelegate {
        private let padding = CGFloat(4)
        
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
    
    final class Text: UITextView {
        private weak var height: NSLayoutConstraint!
        
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
            alwaysBounceVertical = true
            textColor = .white
            tintColor = .halo
            keyboardDismissMode = .interactive
            font = .light(18)
            keyboardType = .alphabet
            keyboardAppearance = .dark
            autocorrectionType = .yes
            spellCheckingType = .yes
            autocapitalizationType = .sentences
            contentInset = .zero
            indicatorStyle = .white
            textContainerInset = .init(top: 16, left: 16, bottom: 30, right: 16)
        }
        
        override func caretRect(for position: UITextPosition) -> CGRect {
            var rect = super.caretRect(for: position)
            rect.size.width += 3
            return rect
        }
    }
    
    private(set) weak var text: Text!
    private weak var menu: Menu!
    
    required init?(coder: NSCoder) { return nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let text = Text()
        text.delegate = self
        addSubview(text)
        self.text = text
        
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
        
        text.topAnchor.constraint(equalTo: topAnchor).isActive = true
        text.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        text.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        text.bottomAnchor.constraint(equalTo: menu.topAnchor).isActive = true
        
        menu.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        menu.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        menu.bottom = menu.bottomAnchor.constraint(equalTo: bottomAnchor)
        
        indicator.widthAnchor.constraint(equalToConstant: 70).isActive = true
        indicator.heightAnchor.constraint(equalToConstant: 40).isActive = true
        indicator.bottomAnchor.constraint(equalTo: menu.topAnchor).isActive = true
        indicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) {
            self.menu.bottom.constant = { $0.minY < self.frame.height ? -$0.height : 0 } (($0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue)
            UIView.animate(withDuration: ($0.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue) {
             self.layoutIfNeeded() }
        }
    }
    
    func textViewDidChange(_: UITextView) { app.desk.content = text.text }
}
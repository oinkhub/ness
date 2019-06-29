import UIKit

final class Settings: UIView {
    private final class Check: UIView {
        private(set) weak var label: UILabel!
        private(set) weak var button: UIButton!
        
        required init?(coder: NSCoder) { return nil }
        init() {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let border = UIView()
            border.translatesAutoresizingMaskIntoConstraints = false
            border.backgroundColor = UIColor.halo.withAlphaComponent(0.3)
            border.isUserInteractionEnabled = false
            addSubview(border)
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = .white
            label.font = .systemFont(ofSize: 14, weight: .regular)
            addSubview(label)
            self.label = label
            
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setImage(UIImage(named: "checkOff"), for: .normal)
            button.setImage(UIImage(named: "checkOn"), for: .selected)
            addSubview(button)
            self.button = button
            
            heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            button.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            button.topAnchor.constraint(equalTo: topAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            button.widthAnchor.constraint(equalToConstant: 70).isActive = true
            
            border.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            border.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
            border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        }
    }
    
    private weak var bottom: NSLayoutConstraint!
    private weak var right: NSLayoutConstraint!
    private weak var size: UILabel!
    
    required init?(coder: NSCoder) { return nil }
    @discardableResult init() {
        super.init(frame: .zero)
        app.window!.endEditing(true)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .black
        app.view.addSubview(self)
        
        let top = UIView()
        top.translatesAutoresizingMaskIntoConstraints = false
        top.backgroundColor = .halo
        top.isUserInteractionEnabled = false
        addSubview(top)
        
        let left = UIView()
        left.translatesAutoresizingMaskIntoConstraints = false
        left.backgroundColor = .halo
        left.isUserInteractionEnabled = false
        addSubview(left)
        
        let close = UIButton()
        close.translatesAutoresizingMaskIntoConstraints = false
        close.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        close.setImage(UIImage(named: "close"), for: .normal)
        close.imageView!.contentMode = .center
        close.imageView!.clipsToBounds = true
        addSubview(close)
        
        let logo = UIImageView(image: UIImage(named: "logo"))
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.contentMode = .scaleAspectFit
        logo.clipsToBounds = true
        addSubview(logo)
        
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = .halo
        border.isUserInteractionEnabled = false
        addSubview(border)
        
        let version = UILabel()
        version.translatesAutoresizingMaskIntoConstraints = false
        version.attributedText = {
            $0.append(NSAttributedString(string: .key("Settings.title"), attributes: [.foregroundColor: UIColor.halo, .font: UIFont.systemFont(ofSize: 16, weight: .bold)]))
            $0.append(NSAttributedString(string: (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String), attributes: [.foregroundColor: UIColor.halo.withAlphaComponent(0.8), .font: UIFont.systemFont(ofSize: 12, weight: .bold)]))
            return $0
        } (NSMutableAttributedString())
        addSubview(version)
        
        let spell = Check()
        spell.label.text = .key("Settings.spell")
        spell.button.isSelected = app.session.spell
        spell.button.addTarget(self, action: #selector(self.spell(_:)), for: .touchUpInside)
        
        let numbers = Check()
        numbers.label.text = .key("Settings.numbers")
        numbers.button.isSelected = app.session.numbers
        numbers.button.addTarget(self, action: #selector(self.numbers(_:)), for: .touchUpInside)
        
        let line = Check()
        line.label.text = .key("Settings.line")
        line.button.isSelected = app.session.line
        line.button.addTarget(self, action: #selector(self.line(_:)), for: .touchUpInside)
        
        let font = UILabel()
        font.translatesAutoresizingMaskIntoConstraints = false
        font.textColor = .white
        font.font = .systemFont(ofSize: 14, weight: .regular)
        font.text = .key("Settings.font")
        addSubview(font)
        
        let size = UILabel()
        size.translatesAutoresizingMaskIntoConstraints = false
        size.textColor = .white
        size.font = .systemFont(ofSize: 14, weight: .bold)
        size.text = "\(Int(app.session.size))"
        addSubview(size)
        self.size = size
        
        let segment = UISegmentedControl(items: [String.key("Settings.mono"), String.key("Settings.regular")])
        segment.addTarget(self, action: #selector(self.segmented(_:)), for: .valueChanged)
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.tintColor = .halo
        segment.selectedSegmentIndex = app.session.font == .SanFranciscoMono ? 0 : 1
        addSubview(segment)
        
        let slider = UISlider()
        slider.addTarget(self, action: #selector(self.slider(_:)), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 11
        slider.maximumValue = 30
        slider.value = Float(Int(app.session.size))
        slider.minimumTrackTintColor = .halo
        slider.maximumTrackTintColor = UIColor.halo.withAlphaComponent(0.3)
        addSubview(slider)
        
        top.topAnchor.constraint(equalTo: topAnchor).isActive = true
        top.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        top.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        top.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        left.topAnchor.constraint(equalTo: topAnchor).isActive = true
        left.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        left.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        left.widthAnchor.constraint(equalToConstant: 2).isActive = true
        
        close.topAnchor.constraint(equalTo: topAnchor).isActive = true
        close.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        close.widthAnchor.constraint(equalToConstant: 50).isActive = true
        close.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        logo.widthAnchor.constraint(equalToConstant: 40).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 40).isActive = true
        logo.topAnchor.constraint(equalTo: topAnchor, constant: 80).isActive = true
        logo.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -60).isActive = true
        
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 2).isActive = true
        border.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: -4).isActive = true
        
        version.bottomAnchor.constraint(equalTo: border.topAnchor, constant: 1).isActive = true
        version.leftAnchor.constraint(equalTo: logo.rightAnchor, constant: 40).isActive = true
        
        var origin = border.bottomAnchor
        [spell, numbers, line].enumerated().forEach {
            addSubview($0.1)
            $0.1.topAnchor.constraint(equalTo: origin, constant: $0.0 == 0 ? 20 : 0).isActive = true
            $0.1.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            $0.1.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            origin = $0.1.bottomAnchor
        }
        
        font.topAnchor.constraint(equalTo: origin, constant: 30).isActive = true
        font.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        
        size.centerYAnchor.constraint(equalTo: segment.centerYAnchor).isActive = true
        size.rightAnchor.constraint(equalTo: segment.leftAnchor, constant: -10).isActive = true
        
        segment.centerYAnchor.constraint(equalTo: font.centerYAnchor).isActive = true
        segment.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        
        slider.topAnchor.constraint(equalTo: segment.bottomAnchor, constant: 50).isActive = true
        slider.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        slider.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true

        widthAnchor.constraint(equalTo: app.view.widthAnchor, constant: 2).isActive = true
        heightAnchor.constraint(equalTo: app.view.heightAnchor, constant: 2).isActive = true
        bottom = topAnchor.constraint(equalTo: app.view.topAnchor, constant: app.view.frame.height)
        right = leftAnchor.constraint(equalTo: app.view.leftAnchor, constant: app.view.frame.width)
        bottom.isActive = true
        right.isActive = true
        app.view.layoutIfNeeded()
        
        bottom.constant = -2
        right.constant = -2
        UIView.animate(withDuration: 0.5) { app.view.layoutIfNeeded() }
    }
    
    @objc private func close() {
        bottom.constant = app.view.frame.height
        right.constant = app.view.frame.width
        UIView.animate(withDuration: 0.4, animations: {
            app.view.layoutIfNeeded()
        }) { [weak self] _ in self?.removeFromSuperview() }
    }
    
    @objc private func spell(_ button: Button) {
        button.isSelected.toggle()
        app.session.spell = button.isSelected
    }
    
    @objc private func numbers(_ button: Button) {
        button.isSelected.toggle()
        app.session.numbers = button.isSelected
    }
    
    @objc private func line(_ button: Button) {
        button.isSelected.toggle()
        app.session.line = button.isSelected
    }
    
    @objc private func slider(_ slider: UISlider) {
        app.session.size = CGFloat(round(slider.value))
        size.text = "\(Int(app.session.size))"
    }
    
    @objc private func segmented(_ segmented: UISegmentedControl) {
        app.session.font = {
            switch $0 {
            case 0: return .SanFranciscoMono
            default: return .SanFrancisco
            }
        } (segmented.selectedSegmentIndex)
    }
}


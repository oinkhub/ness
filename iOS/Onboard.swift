import UIKit

final class Onboard: UIView {
    required init?(coder: NSCoder) { return nil }
    @discardableResult init() {
        super.init(frame: .zero)
        alpha = 0
        translatesAutoresizingMaskIntoConstraints = false
        app.view.addSubview(self)
        
        topAnchor.constraint(equalTo: app.view.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: app.view.bottomAnchor).isActive = true
        leftAnchor.constraint(equalTo: app.view.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: app.view.rightAnchor).isActive = true
        
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.isUserInteractionEnabled = false
        blur.alpha = 0.7
        addSubview(blur)
        
        let type = UILabel()
        type.text = .key("Onboard.type")
        
        let new = UILabel()
        new.text = .key("Onboard.new")
        
        let open = UILabel()
        open.text = .key("Onboard.open")
        
        let settings = UILabel()
        settings.text = .key("Onboard.settings")
        
        let right = UIView()
        let middle = UIView()
        let left = UIView()
        
        let close = UIButton()
        close.translatesAutoresizingMaskIntoConstraints = false
        close.setTitle(.key("Onboard.close"), for: [])
        close.setTitleColor(.black, for: .normal)
        close.setTitleColor(.init(white: 0, alpha: 0.2), for: .highlighted)
        close.backgroundColor = .halo
        close.layer.cornerRadius = 4
        close.titleLabel!.font = .systemFont(ofSize: 14, weight: .bold)
        close.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        addSubview(close)

        blur.topAnchor.constraint(equalTo: topAnchor).isActive = true
        blur.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        blur.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        blur.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        [type, new, open, settings].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = UIColor.halo.withAlphaComponent(0.2)
            $0.textColor = .init(white: 1, alpha: 0.6)
            $0.font = .systemFont(ofSize: 12, weight: .medium)
            $0.layer.cornerRadius = 18
            $0.clipsToBounds = true
            $0.textAlignment = .center
            addSubview($0)
            
            $0.heightAnchor.constraint(equalToConstant: 36).isActive = true
        }
        
        [right, middle, left].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isUserInteractionEnabled = false
            $0.backgroundColor = UIColor.halo.withAlphaComponent(0.2)
            addSubview($0)
            
            $0.widthAnchor.constraint(equalToConstant: 2).isActive = true
            $0.bottomAnchor.constraint(equalTo: app.edit.menu.topAnchor, constant: 13).isActive = true
        }
        
        type.leftAnchor.constraint(equalTo: leftAnchor, constant: 50).isActive = true
        type.widthAnchor.constraint(equalToConstant: 110).isActive = true
        
        settings.topAnchor.constraint(equalTo: type.bottomAnchor, constant: 40).isActive = true
        settings.rightAnchor.constraint(equalTo: rightAnchor, constant: -25).isActive = true
        settings.widthAnchor.constraint(equalToConstant: 170).isActive = true
        
        open.topAnchor.constraint(equalTo: settings.bottomAnchor, constant: 20).isActive = true
        open.rightAnchor.constraint(equalTo: rightAnchor, constant: -95).isActive = true
        open.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        new.topAnchor.constraint(equalTo: open.bottomAnchor, constant: 20).isActive = true
        new.rightAnchor.constraint(equalTo: rightAnchor, constant: -165).isActive = true
        new.widthAnchor.constraint(equalToConstant: 130).isActive = true
        
        right.rightAnchor.constraint(equalTo: settings.rightAnchor, constant: -20).isActive = true
        right.topAnchor.constraint(equalTo: settings.bottomAnchor).isActive = true
        
        middle.rightAnchor.constraint(equalTo: open.rightAnchor, constant: -20).isActive = true
        middle.topAnchor.constraint(equalTo: open.bottomAnchor).isActive = true
        
        left.rightAnchor.constraint(equalTo: new.rightAnchor, constant: -20).isActive = true
        left.topAnchor.constraint(equalTo: new.bottomAnchor).isActive = true
        
        close.topAnchor.constraint(equalTo: new.bottomAnchor, constant: 60).isActive = true
        close.rightAnchor.constraint(equalTo: new.rightAnchor, constant: -70).isActive = true
        close.widthAnchor.constraint(equalToConstant: 96).isActive = true
        close.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        if #available(iOS 11.0, *) {
            type.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        } else {
            type.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        }
        
        UIView.animate(withDuration: 3) { [weak self] in self?.alpha = 1 }
    }
    
    @objc private func close() {
        app.session.onboard = false
        UIView.animate(withDuration: 0.6, animations: { [weak self] in self?.alpha = 0 }) { [weak self] _ in
            self?.removeFromSuperview()
        }
    }
}

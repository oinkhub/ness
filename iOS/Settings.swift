import UIKit

final class Settings: UIView {
    private weak var bottom: NSLayoutConstraint!
    private weak var right: NSLayoutConstraint!
    
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
        
        let market = UIButton()
        market.translatesAutoresizingMaskIntoConstraints = false
        market.setImage(UIImage(named: "market"), for: .normal)
        market.imageView!.clipsToBounds = true
        market.imageView!.contentMode = .center
        addSubview(market)
        
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
        logo.topAnchor.constraint(equalTo: topAnchor, constant: 100).isActive = true
        logo.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        
        widthAnchor.constraint(equalTo: app.view.widthAnchor).isActive = true
        heightAnchor.constraint(equalTo: app.view.heightAnchor).isActive = true
        bottom = topAnchor.constraint(equalTo: app.view.topAnchor, constant: app.view.frame.height)
        right = leftAnchor.constraint(equalTo: app.view.leftAnchor, constant: app.view.frame.width)
        bottom.isActive = true
        right.isActive = true
        app.view.layoutIfNeeded()
        
        bottom.constant = 0
        right.constant = 0
        UIView.animate(withDuration: 0.5) { app.view.layoutIfNeeded() }
    }
    
    @objc private func close() {
        bottom.constant = app.view.frame.height
        right.constant = app.view.frame.width
        UIView.animate(withDuration: 0.4, animations: {
            app.view.layoutIfNeeded()
        }) { [weak self] _ in self?.removeFromSuperview() }
    }
}


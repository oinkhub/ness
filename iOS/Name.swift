import UIKit

final class Name: Sheet, UITextFieldDelegate {
    private let discard: (() -> Void)
    private let result: ((String) -> Void)
    private weak var name: UITextField!
    
    required init?(coder: NSCoder) { return nil }
    @discardableResult init(discard: @escaping(() -> Void), result: @escaping((String) -> Void)) {
        self.discard = discard
        self.result = result
        super.init()
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = .key("Name.title")
        title.font = .systemFont(ofSize: 16, weight: .bold)
        title.textColor = .halo
        addSubview(title)
        
        let name = UITextField()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.tintColor = .halo
        name.textColor = .white
        name.delegate = self
        name.font = .light(16)
        name.autocorrectionType = .no
        name.autocapitalizationType = .none
        name.spellCheckingType = .no
        name.clearButtonMode = .never
        name.keyboardAppearance = .dark
        name.keyboardType = .alphabet
        base.addSubview(name)
        self.name = name
        
        let border = UIView()
        border.isUserInteractionEnabled = true
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = .halo
        base.addSubview(border)
        
        let save = Button.Yes(.key("Name.save"))
        save.addTarget(self, action: #selector(self.save), for: .touchUpInside)
        base.addSubview(save)
        
        let discard = Button.No(.key("Name.discard"))
        discard.addTarget(self, action: #selector(self.discarding), for: .touchUpInside)
        base.addSubview(discard)
        
        let cancel = Button.No(.key("Name.cancel"))
        cancel.addTarget(self, action: #selector(close), for: .touchUpInside)
        base.addSubview(cancel)
        
        title.centerYAnchor.constraint(equalTo: name.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 20).isActive = true
        title.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        name.topAnchor.constraint(equalTo: base.topAnchor, constant: 20).isActive = true
        name.heightAnchor.constraint(equalToConstant: 50).isActive = true
        name.leftAnchor.constraint(equalTo: title.rightAnchor).isActive = true
        name.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -20).isActive = true
        
        border.topAnchor.constraint(equalTo: name.bottomAnchor).isActive = true
        border.leftAnchor.constraint(equalTo: name.leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -20).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        save.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 30).isActive = true
        save.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        
        discard.topAnchor.constraint(equalTo: save.bottomAnchor, constant: 30).isActive = true
        discard.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        
        cancel.topAnchor.constraint(equalTo: discard.bottomAnchor, constant: 20).isActive = true
        cancel.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        cancel.bottomAnchor.constraint(equalTo: base.bottomAnchor, constant: -30).isActive = true
        
        name.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_: UITextField) -> Bool {
        name.resignFirstResponder()
        return true
    }
    
    @objc private func save() {
        close()
        result(name.text!)
    }
    
    @objc private func discarding() {
        close()
        discard()
    }
}

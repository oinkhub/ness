import UIKit

extension UIFont {
    class func light(_ size: CGFloat) -> UIFont { return UIFont(name: "SFMono-Light", size: size)! }
    class func bold(_ size: CGFloat) -> UIFont { return UIFont(name: "SFMono-Bold", size: size)! }
}

extension UIColor {
    static let halo = #colorLiteral(red: 0.231372549, green: 0.7215686275, blue: 1, alpha: 1)
}

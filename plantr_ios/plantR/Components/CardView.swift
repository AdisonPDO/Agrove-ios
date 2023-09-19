import UIKit

@IBDesignable
class CardView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 2

    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 2
    @IBInspectable var shadowColor: UIColor? = UIColor.gray
    @IBInspectable var shadowOpacity: Float = 0.5

    override func layoutSubviews() {
        layer.cornerRadius = 10
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)

        layer.masksToBounds = false
        layer.backgroundColor = UIColor.white.cgColor
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }

}

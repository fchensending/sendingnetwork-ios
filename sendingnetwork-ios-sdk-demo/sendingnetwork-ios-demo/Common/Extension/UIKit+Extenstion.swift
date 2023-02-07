//
//  UIKit+Extenstion.swift
//  ZuJuan
//
//  Created by ch on 2021/9/22.
//

import UIKit

extension UIColor {
    
    static let hex969696 = UIColor(hex: "#969696")
    
    static let hex333333 = UIColor(named: "#333333") ?? UIColor(hex: "#333333")
    
    static let hex666666 = UIColor(named: "#666666") ?? UIColor(hex: "#666666")
    
    static let hex888888 = UIColor(named: "#888888") ?? UIColor(hex: "#888888")
    
    static let hex999999 = UIColor(named: "#999999") ?? UIColor(hex: "#999999")
    
    static let hexDCDCDC = UIColor(named: "#DCDCDC") ?? UIColor(hex: "#DCDCDC")
    
    static let hexE6E6E6 = UIColor(named: "#E6E6E6") ?? UIColor(hex: "#E6E6E6")
 
    static let hex947045 = UIColor(named: "#947045") ?? UIColor(hex: "#947045")
    
    static let hex8F5F28 = UIColor(named: "#8F5F28") ?? UIColor(hex: "#8F5F28")
    
    static let hexF5F6FB = UIColor(named: "#F5F6FB") ?? UIColor(hex: "#F5F6FB")
    
    static let hexFF4C3B = UIColor(named: "#FF4C3B") ?? UIColor(hex: "#FF4C3B")
    
    static let hexF9FAF9 = UIColor(named: "#F9FAF9") ?? UIColor(hex: "#F9FAF9")
    
    static let hex454545 = UIColor(named: "#454545") ?? UIColor(hex: "#454545")

    static let themeGray = UIColor(named: "themeGray") ?? UIColor(hex: "#F7F8F9")
    
    static let themeBlue = UIColor(named: "themeBlue") ?? UIColor(hex: "#2299FF")
    
    static let disableBlue = UIColor(named: "disableBlue") ?? UIColor(hex: "#B3D4FE")
    
    static let titleLabel = UIColor(named: "titleLabel") ?? UIColor(hex: "#3B3B3B")
    
    static func randomColor() -> UIColor {
        return UIColor(red: Int(arc4random()) % 256, green: Int(arc4random()) % 256, blue: Int(arc4random()) % 256)
    }
}

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(red: Int, green: Int, blue: Int, a: CGFloat) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: a)
    }
    
    convenience init(hexa: Int) {
        self.init(red: Int((hexa >> 24) & 0xFF), green: Int((hexa >> 16) & 0xFF), blue: Int((hexa >> 8) & 0xFF), a: CGFloat(hexa & 0xFF) )
    }
    
    convenience init(rgb: Int) {
        self.init(red: (rgb >> 16) & 0xFF, green: (rgb >> 8) & 0xFF, blue: rgb & 0xFF )
    }
    
    /// - Parameter hex: "#32ca73"、"0x32ca73"、"0X32ca73"
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") {
            hex = String(hex.dropFirst())
        }
        
        var reslut: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&reslut)
         
        let mask = 0x000000FF
        let r = Int(reslut >> 16) & mask
        let g = Int(reslut >> 8) & mask
        let b = Int(reslut) & mask
        
        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
   
    /// UIColor -> Hex String
    var hexString: String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        let multiplier = CGFloat(255.999999)
        
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        
        if alpha == 1.0 {
            return String(
                format: "#%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier)
            )
        } else {
            return String(
                format: "#%02lX%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier),
                Int(alpha * multiplier)
            )
        }
    }
    
    /// UIColor -> UIImage
    var image: UIImage? {
        let size = CGSize(width: 1, height: 1)
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    var components: (CGFloat, CGFloat, CGFloat, CGFloat) {
        guard let c = cgColor.components else { return (0, 0, 0, 1) }
        if cgColor.numberOfComponents == 1 {
            return (0, 0, 0, 1)
        } else if cgColor.numberOfComponents == 2 {
            return (c[0], c[0], c[0], c[1])
        } else {
            return (c[0], c[1], c[2], c[3])
        }
    }

    /// http://stackoverflow.com/a/35853850
    static func interpolate(from: UIColor, to: UIColor, with fraction: CGFloat) -> UIColor {
        let f = min(1, max(0, fraction))
        let c1 = from.components
        let c2 = to.components
        let r = c1.0 + (c2.0 - c1.0) * f
        let g = c1.1 + (c2.1 - c1.1) * f
        let b = c1.2 + (c2.2 - c1.2) * f
        let a = c1.3 + (c2.3 - c1.3) * f
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
}

extension UIButton {
    
    enum ImagePlacement {
        case top, left, right, bottom
    }
 
    func setImagePosition(_ position: ImagePlacement, space: CGFloat) {
        guard let imageView = imageView,
              let titleLabel = titleLabel else { return }
        
        if #available(iOS 15.0, *) {
//            var config = UIButton.Configuration.plain()
//            config.imagePlacement = .top
//            config.imagePadding = space
//            configuration = config
//            return
         }
         
        let imgW = imageView.intrinsicContentSize.width
        let imgH = imageView.intrinsicContentSize.height
        let labW = titleLabel.intrinsicContentSize.width
        let labH = titleLabel.intrinsicContentSize.height
        
        let imgOffsetX = labW / 2
        let imgOffsetY = (imgH + space) / 2
        let labOffsetX = imgW / 2
        let labOffsetY = (labH + space) / 2
        
        let tempW = max(labW, imgW)
        let tempH = max(labH, imgH)
        let changeW = labW + imgW - tempW
        let changeH = labH + imgH + space - tempH
        
        let halfSpace = space / 2
        switch position {
        case .top:
            contentVerticalAlignment = .center
            contentHorizontalAlignment = .center
            imageEdgeInsets = UIEdgeInsets(top: -imgOffsetY, left: imgOffsetX, bottom: imgOffsetY, right: -imgOffsetX)
            titleEdgeInsets = UIEdgeInsets(top: labOffsetY, left: -labOffsetX, bottom: -labOffsetY, right: labOffsetX)
            contentEdgeInsets = UIEdgeInsets(top: imgOffsetY, left: -changeW / 2, bottom: changeH - imgOffsetY, right: -changeW / 2)
        case .left:
            contentVerticalAlignment = .center
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -halfSpace, bottom: 0, right: halfSpace)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: halfSpace, bottom: 0, right: -halfSpace)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: halfSpace, bottom: 0, right: halfSpace)
        case .bottom:
            contentVerticalAlignment = .center
            contentHorizontalAlignment = .center
            imageEdgeInsets = UIEdgeInsets(top: imgOffsetY, left: imgOffsetX, bottom: -imgOffsetY, right: -imgOffsetX)
            titleEdgeInsets = UIEdgeInsets(top: -labOffsetY, left: -labOffsetX, bottom: labOffsetY, right: labOffsetX)
            contentEdgeInsets = UIEdgeInsets(top: changeH - imgOffsetY, left: -changeW / 2, bottom: imgOffsetY, right: -changeW / 2)
        case .right:
            contentVerticalAlignment = .center
            imageEdgeInsets = UIEdgeInsets(top: 0, left: labW + halfSpace, bottom: 0, right: -(labW + halfSpace))
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -(imgW + halfSpace), bottom: 0, right: imgW + halfSpace)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: halfSpace, bottom: 0, right: halfSpace)
        }
        
    }
    
    
    func updateImagePosition(_ position: ImagePlacement, space: CGFloat) {
        guard let imageView = imageView,
              let titleLabel = titleLabel else { return }
        
        let imgW = imageView.intrinsicContentSize.width
        let imgH = imageView.intrinsicContentSize.height
        let labW = titleLabel.width
        let labH = titleLabel.height
        
        let imgOffsetX = labW / 2
        let imgOffsetY = (imgH + space) / 2
        let labOffsetX = imgW / 2
        let labOffsetY = (labH + space) / 2
        
        let tempW = max(labW, imgW)
        let tempH = max(labH, imgH)
        let changeW = labW + imgW - tempW
        let changeH = labH + imgH + space - tempH
        
        let halfSpace = space / 2
        switch position {
        case .top:
            contentVerticalAlignment = .center
            contentHorizontalAlignment = .center
            imageEdgeInsets = UIEdgeInsets(top: -imgOffsetY, left: imgOffsetX, bottom: imgOffsetY, right: -imgOffsetX)
            titleEdgeInsets = UIEdgeInsets(top: labOffsetY, left: -labOffsetX, bottom: -labOffsetY, right: labOffsetX)
            contentEdgeInsets = UIEdgeInsets(top: imgOffsetY, left: -changeW / 2, bottom: changeH - imgOffsetY, right: -changeW / 2)
        case .left:
            contentVerticalAlignment = .center
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -halfSpace, bottom: 0, right: halfSpace)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: halfSpace, bottom: 0, right: -halfSpace)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: halfSpace, bottom: 0, right: halfSpace)
        case .bottom:
            contentVerticalAlignment = .center
            contentHorizontalAlignment = .center
            imageEdgeInsets = UIEdgeInsets(top: imgOffsetY, left: imgOffsetX, bottom: -imgOffsetY, right: -imgOffsetX)
            titleEdgeInsets = UIEdgeInsets(top: -labOffsetY, left: -labOffsetX, bottom: labOffsetY, right: labOffsetX)
            contentEdgeInsets = UIEdgeInsets(top: changeH - imgOffsetY, left: -changeW / 2, bottom: imgOffsetY, right: -changeW / 2)
        case .right:
            contentVerticalAlignment = .center
            imageEdgeInsets = UIEdgeInsets(top: 0, left: labW + halfSpace, bottom: 0, right: -(labW + halfSpace))
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -(imgW + halfSpace), bottom: 0, right: imgW + halfSpace)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: halfSpace, bottom: 0, right: halfSpace)
        }
        
    }
    
    func confirmSet() {
        setBackgroundImage(.init(color: .themeBlue), for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .pingFangSCFont(ofSize: 16, weight: .semibold)
        cornerRadius = 22
    }
}

extension UIWindow {
    
    /// topViewController
    static var topViewController: UIViewController? {
        keyWindow?.rootViewController?.currentViewController
    }
    
    /// UIWindow safe layout
    /// https://mp.weixin.qq.com/s/Ik2zBox3_w0jwfVuQUJAUw
    static var layoutInsets: UIEdgeInsets {
        guard let keyWindow = keyWindow else {
            if let unattached = unattached {
                return unattached.safeAreaInsets
            }
            return .zero
        }
        
        if #available(iOS 11.0, *), keyWindow.safeAreaInsets.bottom > 0 {
            return keyWindow.safeAreaInsets
        }
        
        return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    static var keyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }.first?.windows
                .first(where: { $0.isKeyWindow })
        }
        return UIApplication.shared.keyWindow
    }
    
    static var unattached: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first(where: { $0.activationState == .unattached })?.windows.first
        }
        return nil
    }

}

extension Double {
    
    var playerTime: String {
        if self.isNaN {
            return "00:00"
        }
        
        var sec = 0, min = 0, hour = 0, time = Int(self)
        if time < 60 {
            return String(format: "00:%02d", time)
        } else if time < 60 * 60 {
            sec = time % 60
            min = time / 60
            return String(format: "%02d:%02d", min, sec)
        } else {
            sec = time % 60
            min = time / 60 % 60
            hour = time / 60 / 60
            return String(format: "%02d:%02d:%02d", hour, min, sec)
        }
    }
    
}

extension CGFloat {
    
    /// margin
    static let margin: CGFloat = 15.0
    
    static let navBarHeight: CGFloat = 44.0
    
    static let layoutInsets: UIEdgeInsets = UIWindow.layoutInsets
    
    static let safeAreaTop: CGFloat = UIWindow.layoutInsets.top
    
    static let safeAreaBottom: CGFloat = UIWindow.layoutInsets.bottom
    
    static let tabBarHeight: CGFloat = UIWindow.layoutInsets.bottom + 49.0
    
    static let navStatusBarHeight: CGFloat = UIWindow.layoutInsets.top + navBarHeight
    
    static let screenWidth: CGFloat = UIScreen.main.bounds.size.width
    
    static let screenHeight: CGFloat = UIScreen.main.bounds.size.height
    
    static var statusBarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.size.height ?? 44
        } else {
            return UIApplication.shared.statusBarFrame.size.height
        }
    }
    
}

extension UIView {
    
    var x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame = CGRect(x: newValue, y: y, width: width, height: height)
        }
    }
    
    var y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame = CGRect(x: x, y: newValue, width: width, height: height)
        }
    }
    
    var centerX : CGFloat {
        get {
            return center.x
        }
        set {
            center = CGPoint(x: newValue, y: center.y)
        }
    }
    
    var centerY : CGFloat {
        get {
            return center.y
        }
        set {
            center = CGPoint(x: center.x, y: newValue)
        }
    }
    
    var width: CGFloat {
        get {
            return frame.width
        }
        set {
            frame = CGRect(x: x, y: y, width: newValue, height: height)
        }
    }
    
    var height: CGFloat {
        get {
            return frame.height
        }
        set {
            frame = CGRect(x: x, y: y, width: width, height: newValue)
        }
    }
    
    var size: CGSize {
        get {
            return frame.size
        }
        set {
            frame = CGRect(origin: origin, size: newValue)
        }
    }
    
    var origin: CGPoint {
        get {
            return frame.origin
        }
        set {
            frame = CGRect(origin: newValue, size: size)
        }
    }
    
    var maxX: CGFloat {
        get {
            return frame.maxX
        }
        set {
            var temp = frame
            temp.origin.x = newValue - width
            frame = temp
        }
    }
    
    var maxY: CGFloat {
        get {
            return frame.maxY
        }
        set {
            var temp = frame
            temp.origin.y = newValue - height
            frame = temp
        }
    }
    
    var left: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame = CGRect(x: newValue, y: y, width: width, height: height)
        }
    }
    
    var right: CGFloat {
        get {
            return frame.maxX
        }
        set {
            var temp = frame
            temp.origin.x = newValue - width
            frame = temp
        }
    }
    
    var top: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame = CGRect(x: x, y: newValue, width: width, height: height)
        }
    }
    
    var bottom: CGFloat {
        get {
            return frame.maxY
        }
        set {
            var temp = frame
            temp.origin.y = newValue - height
            frame = temp
        }
    }
    
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
 
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor ?? UIColor.clear.cgColor)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
    
    /// Search up the view hierarchy of the table view cell to find the containing table view cell
    var tableViewCell: UITableViewCell? {
        get {
            var cell: UIView? = superview
            while !(cell is UITableViewCell) && cell != nil {
                cell = cell?.superview
            }
            return cell as? UITableViewCell
        }
    }
    
    /// Search up UICollectionViewCell
    var collectionViewCell: UICollectionViewCell? {
        get {
            var cell: UIView? = superview
            while !(cell is UICollectionViewCell) && cell != nil {
                cell = cell?.superview
            }
            return cell as? UICollectionViewCell
        }
    }
    
    var topViewController: UIViewController? {
        UIWindow.topViewController
    }
    
    var parentViewController: UIViewController? {
        weak var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
 
    func config(configurate: ((UIView) -> ())?) {
        configurate?(self)
    }
    
    /// Set some or all corners radiuses of view.
    ///
    /// - Parameters:
    ///   - corners: array of corners to change (example: [.bottomLeft, .topRight]).
    ///   - radius: radius for selected corners.
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }
    
    func superview<T: UIView>(for type: T.Type) -> T? {
        superview as? T ?? superview.flatMap { $0.superview(for: T.self) }
    }
    
    func subView<T: UIView>(for type: T.Type) -> T? {
        self as? T ?? subviews.first(where: { $0.isKind(of: type) }) as? T
//        for e in subviews.enumerated() {
//            if e.element.isKind(of: type) {
//                return e.element
//            }
//        }
//        return nil
    }
    
    func removeAllSubViews() {
        subviews.forEach { $0.removeFromSuperview() }
    }
    
    struct CornerRadii {
        var topLeft: CGFloat = 0
        var topRight: CGFloat = 0
        var bottomLeft: CGFloat = 0
        var bottomRight: CGFloat = 0
    }
    
    func addCorner(cornerRadii: CornerRadii) {
        let path = createPath(withRoundRect: bounds, cornerRadii: cornerRadii)
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = bounds
        shapeLayer.path = path
        self.layer.mask = shapeLayer
    }
    
    @discardableResult
    func addTapGesture(_ target: Any?, action: Selector) -> UITapGestureRecognizer {
        isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: target, action: action)
        addGestureRecognizer(gesture)
        return gesture
    }
    
    func addLongPressGesture(_ target: Any?, action: Selector) {
        isUserInteractionEnabled = true
        let gesture = UILongPressGestureRecognizer(target: target, action: action)
        gesture.minimumPressDuration = 0.5
        addGestureRecognizer(gesture)
    }
    
    func createPath(withRoundRect bounds: CGRect, cornerRadii: CornerRadii) -> CGPath {
        let minX = bounds.minX
        let minY = bounds.minY
        let maxX = bounds.maxX
        let maxY = bounds.maxY
        
        let topLeftCenterX = minX + cornerRadii.topLeft
        let topLeftCenterY = minY + cornerRadii.topLeft
        
        let topRightCenterX = maxX - cornerRadii.topRight
        let topRightCenterY = minY + cornerRadii.topRight
        
        let bottomLeftCenterX = minX + cornerRadii.bottomLeft
        let bottomLeftCenterY = maxY - cornerRadii.bottomLeft
        
        let bottomRightCenterX = maxX - cornerRadii.bottomRight
        let bottomRightCenterY = maxY - cornerRadii.bottomRight
        
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: topLeftCenterX, y: topLeftCenterY), radius: cornerRadii.topLeft, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 3 / 2.0, clockwise: false)
        path.addArc(center: CGPoint(x: topRightCenterX, y: topRightCenterY), radius: cornerRadii.topRight, startAngle:  CGFloat.pi * 3 / 2.0, endAngle: 0, clockwise: false)
        path.addArc(center: CGPoint(x: bottomRightCenterX, y: bottomRightCenterY), radius: cornerRadii.bottomRight, startAngle:  0, endAngle: CGFloat.pi / 2, clockwise: false)
        path.addArc(center: CGPoint(x: bottomLeftCenterX, y: bottomLeftCenterY), radius: cornerRadii.bottomLeft, startAngle:  CGFloat.pi / 2.0, endAngle: CGFloat.pi, clockwise: false)
        path.closeSubpath()
        return path
    }
     
    @discardableResult
    func gradientLayer(_ colors: [UIColor]?,
                       isHorizontal: Bool = false,
                       cornerRadius: CGFloat = 0,
                       shadowRadius: CGFloat = 3,
                       shadowColor: UIColor = .clear,
                       shadowOffset: CGSize = .zero) -> CAGradientLayer {
        if let xx = layer.sublayers?.first(where: { type(of: $0) == CAGradientLayer.self }) {
            xx.removeFromSuperlayer()
        }
        
        let gradient = CAGradientLayer()
        layer.addSublayer(gradient)
        
        layoutIfNeeded()
        gradient.frame = bounds
        gradient.zPosition = -1
        gradient.colors = colors?.reversed().map { $0.cgColor }
        
        if isHorizontal {
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 0)
        }
        
        gradient.shadowOpacity = 1
        gradient.shadowRadius = shadowRadius
        gradient.shadowColor = shadowColor.cgColor
        gradient.shadowOffset = shadowOffset
        gradient.cornerRadius = cornerRadius
        
        // The layer is using dynamic shadows which are expensive to render. If possible try setting `shadowPath`, or pre-rendering the shadow into an image and putting it under the layer.
        gradient.shadowPath = UIBezierPath(rect: bounds).cgPath

        return gradient
    }
    
    func setIntrinsicSize(_ isHorizontal: Bool = true) {
        setContentHuggingPriority(.required, for: isHorizontal ? .horizontal : .vertical)
        setContentCompressionResistancePriority(.required, for: isHorizontal ? .horizontal : .vertical)
    }
    
    /// - Parameter angle:
    func rotate(_ animated: Bool = true, _ angle: CGFloat = 180, completion: ((Bool) -> Swift.Void)? = nil) {
        UIView.animate(withDuration: animated ? 0.25 : 0, animations: {
            self.transform = self.transform.rotated(by: angle / 180.0 * .pi)
        }, completion: completion)
    }
    
    
    @IBInspectable var shadowColor: UIColor {
        get {
            return .white
        }
        set {
            layer.shadowColor = newValue.cgColor
        }
    }
    
}

extension UIViewController {
    
    var topItem: UINavigationItem? {
        navigationController?.navigationBar.topItem
    }
    
    var current1: UIViewController? {
        switch self {
        case let vc as UINavigationController:
            return vc.topViewController
        case let vc as UITabBarController:
            return (vc.selectedViewController as? UINavigationController)?.topViewController
        default:
            return presentedViewController ?? self
        }
    }
    
    var currentViewController: UIViewController? {
        if let nav = self as? UINavigationController {
            return nav.topViewController?.currentViewController
        }

        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.currentViewController
        }

        if let presented = presentedViewController {
            return presented.currentViewController
        }

        return self
    }
    
    func present() {
        if UIWindow.topViewController?.presentedViewController == nil
            , UIWindow.topViewController != self {
            UIWindow.topViewController?.present(self, animated: true)
        }
    }
}

extension UIViewController {

  public class func nkReplaceSystemPresent(){

    let systemSelector = #selector(UIViewController.present(_:animated:completion:))

    let nkSelector = #selector(UIViewController.newPesent(_:animated:completion:))

    let systemMethod = class_getInstanceMethod(self, systemSelector)

    let nkNewMethod = class_getInstanceMethod(self, nkSelector)
      
    method_exchangeImplementations(systemMethod!, nkNewMethod!)
      
  }

  @objc public func newPesent(_ vcToPresent:UIViewController, animated flag:Bool, completion: (() ->Void)? = nil) {

    if vcToPresent.isKind(of:UIAlertController.self) {

      let alertController = vcToPresent as? UIAlertController

      if alertController?.title==nil && alertController?.message==nil {
        return
      }
    }

    self.newPesent(vcToPresent, animated: flag)

  }

}
 


extension UINavigationController {
    
    func popTo(_ type: UIViewController.Type) {
        guard let vc = viewControllers.first(where: { $0.isKind(of: type) }) else { return }
        popToViewController(vc, animated: true)
    }
    
}

extension UIStoryboard {
    
    enum Name: String {
        case main
        case home
        case work
        case mine
        case login
        case basket
        case welcome
    }
    
    /// UIStoryboard init
    convenience init(name: Name) {
        self.init(name: name.rawValue.capitalized, bundle: nil)
    }
    
    var instantiateInitial: UIViewController? {
        instantiateInitialViewController()
    }
    
}

extension UITabBar {
    
    func tabBarButton(at index: Int) -> UIControl? {
        subviews.compactMap { $0 as? UIControl }[safe: index]
    }
    
    func tabBarButton(for title: String) -> UIControl? {
        let index = items?.firstIndex(where: { $0.title == title })
        return tabBarButton(at: index ?? 0)
    }

    func itemRect(at index: Int) -> CGRect? {
        var frames = subviews.compactMap { $0 is UIControl ? $0.frame : nil }
        frames.sort { $0.origin.x < $1.origin.x }
        return frames[safe: index]
    }
    
    func itemRect(for title: String) -> CGRect? {
        let index = items?.firstIndex(where: { $0.title == title })
        return itemRect(at: index ?? 0)
    }

}

extension Collection {

    subscript (safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }

}

extension UITableView {
    
    var visibleIndexPaths: [IndexPath] {
        indexPathsForVisibleRows ?? []
    }
    
    struct AssociatedKeys {
        static var imageView = "AssociatedKeys.imageView"
        static var originalFrame = "AssociatedKeys.originalFrame"
        static var observation = "AssociatedKeys.KeyValueObservation"
    }
    

    func scale(frame: CGRect, image: UIImage? = nil) {
        guard objc_getAssociatedObject(self, &AssociatedKeys.imageView) == nil else { return }
        guard objc_getAssociatedObject(self, &AssociatedKeys.observation) == nil else { return }
        guard objc_getAssociatedObject(self, &AssociatedKeys.originalFrame) == nil else { return }
  
        let background = UIImageView(frame: frame)
        background.image = image
        background.contentMode = .scaleAspectFill
        background.clipsToBounds = true
        insertSubview(background, at: 0)

        let oberver = observe(\.contentOffset, options: .new) { object, change in
            self.observeValueChanged()
        }
        
        objc_setAssociatedObject(self, &AssociatedKeys.observation, oberver, .OBJC_ASSOCIATION_RETAIN)
        objc_setAssociatedObject(self, &AssociatedKeys.originalFrame, frame, .OBJC_ASSOCIATION_RETAIN)
        objc_setAssociatedObject(self, &AssociatedKeys.imageView, background, .OBJC_ASSOCIATION_RETAIN)
    }
    
   func observeValueChanged() {
        guard
            let imageView = objc_getAssociatedObject(self, &AssociatedKeys.imageView) as? UIImageView,
            let originalFrame = objc_getAssociatedObject(self, &AssociatedKeys.originalFrame) as? CGRect else {
                return
        }
        
        let offset = contentOffset.y
        if offset < 0 {
            imageView.frame = CGRect(x: offset, y: offset, width: originalFrame.width - 2 * offset, height: originalFrame.height - offset)
        } else {
            imageView.frame = originalFrame
        }
    }
    
    /// https://stackoverflow.com/questions/48017955/ios-tableview-reload-and-scroll-top
    func reloadData(completion: (() -> ())? = nil) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }, completion: { _ in
            completion?()
        })
    }

    /// https://www.jianshu.com/p/820c0209975b
    /// - Parameter title: title description
    func showEmpty(title: String = "The content",
                   imageName: String = "empty_content") {
        let background = UIView(frame: bounds)
         
        let label = UILabel()
        background.addSubview(label)
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = title
        label.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        let imageView = UIImageView()
        background.addSubview(imageView)
        imageView.image = UIImage(named: imageName)
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(label.snp.top).offset(-CGFloat.margin)
        }
    
        backgroundView = background
    }
    
    func hideEmpty() {
        backgroundView?.removeAllSubViews()
        backgroundView = nil
    }
    
    func updateLayout(animated: Bool = false, completion: (() -> ())? = nil) {
        if dataSource == nil {
            return
        }
        
        if animated {
            performBatchUpdates(nil) { _ in
                completion?()
            }
            return
        }
         
        UIView.performWithoutAnimation {
            self.performBatchUpdates(nil) { _ in
                completion?()
            }
        }
    }
}

extension UITableViewCell {
    
    /// Search up the view hierarchy of the table view cell to find the containing table view
    var tableView: UITableView? {
        var table: UIView? = superview
        while !(table is UITableView), table != nil {
            table = table?.superview
        }
        return table as? UITableView
    }
    
    var indexPath: IndexPath? {
        tableView?.indexPathForRow(at: center)
    }
    
    /// indexPath(for: self)
    var indexPath_inaccurate: IndexPath? {
        tableView?.indexPath(for: self)
    }
    
}

extension UICollectionView {
    
    func updateVisibleLayout() {
        let context = UICollectionViewFlowLayoutInvalidationContext()
        context.invalidateItems(at: indexPathsForVisibleItems)
        collectionViewLayout.invalidateLayout(with: context)
    }
    
    func updateLayout() {
        collectionViewLayout.invalidateLayout()
    }
    
    func reloadData(completion: (() -> ())? = nil) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }, completion: { _ in
            completion?()
        })
    }
    
}

extension UICollectionViewCell {

    /// Search up the view hierarchy of the table view cell to find the containing table view
    var collectionView: UICollectionView? {
        var view: UIView? = superview
        while !(view is UICollectionView), view != nil {
            view = view?.superview
        }
        return view as? UICollectionView
    }
    
    var indexPath: IndexPath? {
        collectionView?.indexPathForItem(at: center)
    }
    
    var indexPath_inaccurate: IndexPath? {
        collectionView?.indexPath(for: self)
    }
    
}

extension UICollectionViewLayout {
    
    /// https://stackoverflow.com/questions/57944431/
    /// extensions-must-not-contain-stored-properties-preventing-me-from-refactoring-c/57944914
    private class Weak<V: AnyObject> {
        weak var value: V?
        
        init?(_ value: V?) {
            guard let value = value else { return nil }
            self.value = value
        }
    }

    private struct SEL {
        static let setRowAlignmentsOptions = Selector(("_setRowAlignmentsOptions:"))
    }
    
    private struct Keys {
        static let rowVerticalAlignment = "UIFlowLayoutRowVerticalAlignmentKey"
        
        static let lastRowHorizontalAlignment = "UIFlowLayoutLastRowHorizontalAlignmentKey"
        
        static let commonRowHorizontalAlignment = "UIFlowLayoutCommonRowHorizontalAlignmentKey"
    }
    
    private struct AssociatedKeys {
        static var lastRowHorizontalAlignment: NSTextAlignment = .center
        
        static var commonRowHorizontalAlignment: NSTextAlignment = .justified
    }
    
    /// https://www.jianshu.com/p/de08c2679241
    open var commonRowHorizontalAlignment: NSTextAlignment {
        get {
            guard let alignment = objc_getAssociatedObject(self, &AssociatedKeys.commonRowHorizontalAlignment) as? NSTextAlignment else {
                return .justified
            }
            return alignment
        }
        set {
            let options = [Keys.commonRowHorizontalAlignment : newValue.rawValue]
            perform(SEL.setRowAlignmentsOptions, with: options)
            objc_setAssociatedObject(self, &AssociatedKeys.commonRowHorizontalAlignment,
                                     newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    open var lastRowHorizontalAlignment: NSTextAlignment {
        get {
            guard let alignment = objc_getAssociatedObject(self, &AssociatedKeys.lastRowHorizontalAlignment) as? NSTextAlignment else {
                return .center
            }
            return alignment
        }
        set {
            let options = [Keys.lastRowHorizontalAlignment : newValue.rawValue]
            perform(SEL.setRowAlignmentsOptions, with: options)
            objc_setAssociatedObject(self, &AssociatedKeys.lastRowHorizontalAlignment,
                                     newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

extension UIImage {
    
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1.0, height: 1.0)) {
        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(origin: .zero, size: size))
        context?.setShouldAntialias(true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        guard let cgImage = image?.cgImage else {
            self.init()
            return nil
        }
        
        self.init(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
    }
    
    func change(with size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height);
        draw(in: rect)
        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return output
    }
    
    func change(with color: UIColor) -> UIImage? {
        if #available(iOS 13.0, *) {
            return withTintColor(color)
        }
     
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext(),
              let cgImage = cgImage else { return nil }
    
        let bounds = CGRect(origin: .zero, size: size)
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        context.clip(to: bounds, mask: cgImage)
        color.setFill()
        context.fill(bounds)

        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return output
    }
    
    /// Resizes an image to the specified size.
    ///
    /// - Parameters:
    ///     - size: the size we desire to resize the image to.
    ///     - roundedRadius: corner radius
    ///
    /// - Returns: the resized image with rounded corners.
    ///
    func rounded(with radius: CGFloat = 0, corners: UIRectCorner = .allCorners) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        let rect = CGRect(origin: .zero, size: size)
        context.addPath(UIBezierPath(roundedRect: rect,
                                     byRoundingCorners: corners,
                                     cornerRadii: CGSize(width: radius, height: radius)).cgPath)
        context.clip()
        
        // Don't use CGContextDrawImage, coordinate system origin in UIKit and Core Graphics are vertical oppsite.
        draw(in: rect)
        context.drawPath(using: .fillStroke)
        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return output
    }
    
    /// Resizes an image to the specified size and adds an extra transparent margin at all sides of
    /// the image.
    ///
    /// - Parameters:
    ///     - size: the size we desire to resize the image to.
    ///     - extraMargin: the extra transparent margin to add to all sides of the image.
    ///
    /// - Returns: the resized image.  The extra margin is added to the input image size.  So that
    ///         the final image's size will be equal to:
    ///         `CGSize(width: size.width + extraMargin * 2, height: size.height + extraMargin * 2)`
    ///
    func extra(with margin: CGFloat) -> UIImage? {
        let imageSize = CGSize(width: size.width + margin * 2, height: size.height + margin * 2)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale);
        let rect = CGRect(x: margin, y: margin, width: size.width, height: size.height)
        draw(in: rect)
        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return output
    }
    
}

extension UIResponder {
    
    func nextResponder(of cls: AnyClass) -> UIResponder {
        var nextResponder: UIResponder? = self
        while( nextResponder != nil && !nextResponder!.isKind(of: cls)) {
            nextResponder = nextResponder!.next
        }
        return nextResponder!
    }
    
    func getUIViewController() -> UIViewController {
        return self.nextResponder(of: UIViewController.self) as! UIViewController
    }
    
    
    func getUITabbarController() -> UITabBarController {
        return self.nextResponder(of: UITabBarController.self) as! UITabBarController
    }
}


protocol NibLoadable {
    
}

extension NibLoadable where Self : UIView {
    static func loadFromNib(_ nibname : String? = nil) -> Self {
        let loadName = nibname == nil ? "\(self)" : nibname!
        return Bundle.main.loadNibNamed(loadName, owner: nil, options: nil)?.first as! Self
    }
}

extension NSLayoutConstraint {
    
    func updateMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint? {
        guard let firstItem = firstItem else { return nil }
        NSLayoutConstraint.deactivate([self])
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant
        )
        
        newConstraint.priority = priority
        newConstraint.identifier = identifier
        newConstraint.shouldBeArchived = shouldBeArchived
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
    
}


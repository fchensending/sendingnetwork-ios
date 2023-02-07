//
//  Font.swift
//  ZuJuan
//
//  Created by ch on 2021/10/25.
//

import UIKit

extension UIFont.Weight {
    
    var name: String {
        switch self {
        case .ultraLight:
            return "ultraLight".capitalized
        case .thin:
            return "thin".capitalized
        case .light:
            return "light".capitalized
        case .regular:
            return "regular".capitalized
        case .medium:
            return "medium".capitalized
        case .semibold:
            return "semibold".capitalized
        case .bold:
            return "bold".capitalized
        case .heavy:
            return "heavy".capitalized
        case .black:
            return "black".capitalized
        default:
            return "regular".capitalized
        }
    }
    
}

extension UIFont {
    
    static func pingFangSCFont(ofSize fontSize: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        UIFont(name: "PingFangSC-\(weight.name)", size: fontSize) ?? .systemFont(ofSize: fontSize, weight: weight)
    }
    
}

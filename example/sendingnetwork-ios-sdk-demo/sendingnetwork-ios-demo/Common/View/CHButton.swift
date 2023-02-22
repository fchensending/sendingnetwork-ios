//
//  CHButton.swift
//  sendingnetwork-ios-demo
//
//  Created by chenghao on 2023/1/18.
//

import UIKit

class CHButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        titleLabel?.font = .pingFangSCFont(ofSize: 14, weight: .semibold)
        setTitleColor(UIColor.white, for: .normal)
        setBackgroundImage(UIColor(hex: "#2299FF").image, for: .normal)
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }

}

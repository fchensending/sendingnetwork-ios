//
//  CHCorButton.swift
//  sendingnetwork-ios-demo
//
//  Created by ch on 2023/2/9.
//  Copyright © 2023 sending.network. All rights reserved.
//

import UIKit

class CHCorButton: UIButton {

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
        setTitleColor(.themeBlue, for: .normal)
        layer.cornerRadius = 5
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.themeBlue.cgColor
    }

}

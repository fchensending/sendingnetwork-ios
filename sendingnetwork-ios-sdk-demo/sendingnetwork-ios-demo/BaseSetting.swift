//
//  BaseSetting.swift
//  sendingnetwork-ios-demo
//
//  Created by chenghao on 2023/2/7.
//

import Foundation

class BaseSetting {
    
    static let shared = BaseSetting()
    
    private init() {}
    
//    static let base_url = "http://10.1.5.142:8008"
    static let base_url = "http://127.0.0.1:65432"
    
    var userId: String?
    
    var access_token: String?
    
}

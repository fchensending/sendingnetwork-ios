//
//  CertInfo.swift
//  ZuJuan
//
//  Created by ch on 2022/2/12.
//

import Foundation

struct CertInfo: Decodable {
    var path: String?
    
    var domain: String?
    
    var pubKey: String?
    
    var expiredAt: String?
}

//
//  Credentials.swift
//
//  Created by octopus on 2022/7/15.
//

import Foundation

@objcMembers
public class Credentials : NSObject {
    public init(userName: String, password: String, userId: String, accessToken: String, deviceId: String) {
        self.userName = userName
        self.password = password
        self.userId = userId
        self.accessToken = accessToken
        self.deviceId = deviceId
    }
    
    public let userName: String
    public let password: String
    public let userId: String
    public let accessToken: String
    public let deviceId: String
}

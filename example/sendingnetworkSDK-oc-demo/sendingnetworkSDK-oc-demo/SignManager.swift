//
//  SignManager.swift
//  sendingnetworkSDK-oc-demo
//
//  Created by ch on 2023/2/24.
//

import Foundation
import web3

@objcMembers
class SignManager: NSObject {
    
    @objc static public func signMessage(message: String, privateKey: String) -> String {
        let keyStorage = EthereumKeyLocalStorage()
        let account = try? EthereumAccount.importAccount(replacing: keyStorage, privateKey: privateKey, keystorePassword: "")
        let sign = try? account?.signMessage(message:  Data(message.utf8))
        return sign!
    }
    
}

//
//  File.swift
//  
//
//  Created by octopus on 2022/7/14.
//

import Foundation
import WalletCore
import RNCryptor

public class Web3Wallet: NSObject {
    private let wallet: HDWallet
    
    enum Web3WalletError: Error {
        case WrongPassword
        case NoWallet
        case DataCorrupted
    }

    public init?(_ mnemonic: String?) {
        if (mnemonic ?? "").isEmpty {
            guard let wallet = HDWallet(strength: 128, passphrase: "") else {
                return nil
            }
            self.wallet = wallet
        } else {
            guard let wallet = HDWallet(mnemonic: mnemonic!, passphrase: "") else {
                return nil
            }
            self.wallet = wallet
        }
    }
    
    public var mnemonic : String {
        return wallet.mnemonic
    }
    
    public func getAddressForCoin(coin: CoinType) -> String {
        return wallet.getAddressForCoin(coin: coin)
    }
    
    private func save(password: String) {
        let data = wallet.mnemonic.data(using: String.Encoding.utf8)
        let encryptedData = RNCryptor.encrypt(data: data!, withPassword: password)
        RadixSettings.shared.walletMnemonic = encryptedData.base64EncodedString()
    }
    
    public static var hasSavedWallet: Bool {
        return RadixSettings.shared.hasWalletMnemonic
    }
    
    public static func unlock(password: String) throws -> Web3Wallet? {
        guard let encryptedMnemonic = RadixSettings.shared.walletMnemonic else {
            throw Web3WalletError.NoWallet
        }
        do {
            guard let data = Data(base64Encoded: encryptedMnemonic) else {
                throw Web3WalletError.DataCorrupted
            }
            let decryptedData = try RNCryptor.decrypt(data: data, withPassword: password)
            let mnemonic = String(decoding: decryptedData, as: UTF8.self)
            return Web3Wallet(mnemonic)
        } catch {
            throw Web3WalletError.WrongPassword
        }
    }
    
    public static func new(password: String) -> Web3Wallet? {
        return restore(mnemonic: nil, password: password)
    }
    
    public static func restore(mnemonic: String?, password: String) -> Web3Wallet? {
        let wallet = Web3Wallet(mnemonic)
        if wallet != nil {
            wallet?.save(password: password)
        }
        return wallet
    }
    
}

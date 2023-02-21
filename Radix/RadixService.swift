//
//  File.swift
//  
//
//

import Foundation
import Radixmobile
import RNCryptor

@objc public class RadixService: NSObject {
   
    @objc public static let shared = RadixService()
    // MARK: Setup
    private var radix: RadixmobileRadixMonolith?
    private var timer: Timer?
   
    private override init() {
        super.init()
    }
    
    // MARK: UI-driven functions
    
    @objc public func baseURL() -> String? {
        guard let radix = self.radix else { return nil }
        return radix.baseURL()
    }
    
    @objc public func start() {
        if self.radix == nil {
            guard let storageDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                fatalError("can't get document directory")
            }
            guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                fatalError("can't get caches directory")
            }
            
            self.radix = RadixmobileRadixMonolith()
            self.radix?.storageDirectory = storageDirectory.path
            self.radix?.cacheDirectory = cachesDirectory.path
            
            if !RadixSettings.shared.mainNet {
                self.radix?.testNet = true
            }
            
            NSLog("Storage directory: \(storageDirectory)")
            NSLog("Cache directory: \(cachesDirectory)")
                        
            if RadixSettings.shared.p2pEnableStaticPeer {
                self.setStaticPeer(RadixSettings.shared.p2pStaticPeerURI)
            } else {
                self.setStaticPeer("")
            }
            
            self.setMulticastEnabled(!RadixSettings.shared.p2pDisableMulticast)
        }
        self.radix?.start()
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.printPeers), userInfo: nil, repeats: true)
        }
        self.timer?.fire()
    }
    
    @objc private func printPeers() {
        keepHealth()
    }
    
    @objc private func keepHealth() {
        let destUrl:URL = URL(string: "http://127.0.0.1:65432/_api/client/monitor/health")!
        let session = URLSession.shared
        var request = URLRequest(url: destUrl)
        request.httpMethod = "GET"
        let task: URLSessionDataTask = session.dataTask(with: request) {[weak self] data, response, error in
            guard let self = self else { return }
            guard error == nil, let data:Data = data, let httpResponse :HTTPURLResponse = response as? HTTPURLResponse else {
                debugPrint("server disconnect")
                self.debugShowAlert()
                self.radix?.start()
                return
            }
            if httpResponse.statusCode != 200 {
                debugPrint("server disconnect")
                self.debugShowAlert()
                self.radix?.start()
                return
            }

            print("server connecting")
        }
        task.resume()
    }
    
    @objc private func debugShowAlert() {
        #if DEBUG
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "alert", message: "server diconnect, has connect", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            self.keyWindow?.rootViewController?.present(alert, animated: true)
        }
        #endif
    }
    
    @objc var keyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }.first?.windows
                .first(where: { $0.isKeyWindow })
        }
        return UIApplication.shared.keyWindow
    }
    
    @objc public func stop() {
        if self.radix != nil {
            self.radix?.stop()
        }
        self.timer?.invalidate()
        self.timer = nil
    }
    
    @objc public func setMulticastEnabled(_ enabled: Bool) {
        guard self.radix != nil else { return }
        guard let radix = self.radix else { return }
        radix.setMulticastEnabled(enabled)
    }
    
    @objc public func setStaticPeer(_ uri: String) {
        guard self.radix != nil else { return }
        guard let radix = self.radix else { return }
        radix.setStaticPeer(uri.trimmingCharacters(in: .whitespaces))
    }
    
}


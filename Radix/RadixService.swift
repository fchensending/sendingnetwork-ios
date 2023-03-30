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
   
    private override init() {
        super.init()
    }
    
    private lazy var radixQueue: DispatchQueue = {
        let queue = DispatchQueue(label: "radix")
        return queue
    }()
    
    private lazy var gcdTimer: DispatchSourceTimer? = {
        let timer = DispatchSource.makeTimerSource(queue: radixQueue)
        timer.schedule(deadline: .now(),repeating: .seconds(30))
        timer.setEventHandler(handler: {[weak self] in
            self?.printPeers()
        })
        timer.resume()
        return timer
    }()
    
    // MARK: UI-driven functions
    
    @objc public func baseURL() -> String? {
        guard let radix = self.radix else { return nil }
        return radix.baseURL()
    }
    
    @objc public func start() {
        radixQueue.async {[weak self] in
            guard let self = self else { return }
            if self.radix == nil {
                self.initRadix()
            }
            if let running = self.radix?.running() {
                if !running {
                    self.radix?.start()
                }
            }
            guard let _ = self.gcdTimer else { return }
        }
    }
    
    @objc private func printPeers() {
        keepHealth()
    }
    
    @objc private func initRadix() {
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
        } else {
            self.radix?.testNet = false
        }
        
        if RadixSettings.shared.p2pEnableStaticPeer {
            self.setStaticPeer(RadixSettings.shared.p2pStaticPeerURI)
        } else {
            self.setStaticPeer("")
        }
        self.setMulticastEnabled(!RadixSettings.shared.p2pDisableMulticast)
    }
    
    @objc private func reStart() {
        if self.radix == nil {
            initRadix()
        }
        self.radix?.start()
    }
    
    @objc private func keepHealth() {
        let destUrl:URL = URL(string: "http://localhost:65432/_api/client/monitor/health")!
        let session = URLSession.shared
        var request = URLRequest(url: destUrl)
        request.httpMethod = "GET"
        let task: URLSessionDataTask = session.dataTask(with: request) {[weak self] data, response, error in
            guard let self = self else { return }
            guard error == nil, let httpResponse :HTTPURLResponse = response as? HTTPURLResponse else {
                self.radixQueue.async {
                    self.stop()
                    self.reStart()
                    debugPrint("health fail")
                }
                return
            }
            if httpResponse.statusCode != 200 {
                self.radixQueue.async {
                    self.stop()
                    self.reStart()
                    debugPrint("health fail")
                }
                return
            }
            debugPrint("health success")
        }
        task.resume()
    }
    
    @objc public func stop() {
        if self.radix != nil {
            self.radix?.stop()
        }
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


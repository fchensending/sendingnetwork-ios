//
//  HUD.swift
//  sendingnetwork-ios-demo
//
//  Created by ch on 2023/2/8.
//  Copyright © 2023 sending.network. All rights reserved.
//

import UIKit
import Foundation
import ObjectiveC
import MBProgressHUD

extension MBProgressHUD {
    
    struct AssociatedKeys {
        static var createTime = Date()
    }
    
    var createtime: Date {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.createTime) as? Date) ?? Date()
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.createTime, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
}

struct HUD {
    
    enum Status: String, CustomStringConvertible {
        case info
        case warn
        case error
        case success
        
        var description: String {
            "hud_\(rawValue)"
        }
    }
    
    typealias Completion = () -> ()
    
    private static func createHUD(text: String? = "") -> MBProgressHUD? {
        guard Thread.isMainThread else {
            return nil
        }
        guard let window = UIWindow.keyWindow else {
            return nil
        }
        MBProgressHUD.hide(for: window, animated: true)
        
        let hud = MBProgressHUD.showAdded(to: window, animated: true)
        hud.margin = .margin
        hud.bezelView.style = .solidColor
        hud.bezelView.color = UIColor(white: 0, alpha: 0.8)
        
        hud.detailsLabel.text = text
        hud.detailsLabel.font = .systemFont(ofSize: 15)
        hud.contentColor = .white
        hud.removeFromSuperViewOnHide = true
        hud.isUserInteractionEnabled = true
        hud.createtime = Date()
        
        return hud
    }
    
    /// - Parameter progress
    static func showProgress(_ progress: Double) {
        guard let window = UIWindow.keyWindow else { return }
        guard let hud = MBProgressHUD.forView(window) ?? createHUD() else {
            return
        }
        hud.mode = .annularDeterminate
        hud.progress = Float(progress)
        hud.backgroundView.color = UIColor(white: 0, alpha: 0.3)
    }
    
    static func showLoading(text: String? = "", delay: TimeInterval = 0.0) {
        guard  let hud = createHUD(text: text) else {
            return
        }
        hud.mode = .indeterminate
        hud.backgroundView.color = UIColor(white: 0, alpha: 0.3)
        if delay > 0 {
            hud.hide(animated: true, afterDelay: 2.0)
        }
        
        AddGCDTimer(timeout: 30) {
            hud.hide(animated: true)
        }
    }
    
    static func showLoadingWithoutHide(text: String? = "", delay: TimeInterval = 0.0) {
        guard let hud = createHUD(text: text) else {
            return
        }
        hud.mode = .indeterminate
        hud.backgroundView.color = UIColor(white: 0, alpha: 0.3)
        if delay > 0 {
            hud.hide(animated: true, afterDelay: 2.0)
        }
    }
    
    static func showText(_ text: String? = "", delay: TimeInterval = 2.0, completion: Completion? = nil) {
        guard let hud = createHUD(text: text) else {
            return
        }
        hud.mode = .text
        hud.completionBlock = completion
        hud.isUserInteractionEnabled = false
        hud.hide(animated: true, afterDelay: delay)
    }
    
    static func showImage(text: String? = "",
                          delay: TimeInterval = 2.0,
                          status: Status? = .success,
                          completion: Completion? = nil) {
        guard let hud = createHUD(text: text) else {
            return
        }
        hud.isUserInteractionEnabled = false
        guard let imageNamed = status?.description, let image = UIImage(named: imageNamed) else {
            return
        }
        hud.mode = .customView
        hud.customView = UIImageView(image: image)
        hud.completionBlock = completion
        hud.hide(animated: true, afterDelay: delay)
    }
    
    static func hide() {
        guard let window = UIWindow.keyWindow else {
            return
        }
        MBProgressHUD.hide(for: window, animated: true)
    }
    
    static func hideAll() {
        guard let window = UIWindow.keyWindow else {
            return
        }
        window.subviews.filter({ $0.classForCoder == MBProgressHUD.self }).forEach { hud in
            hud.removeFromSuperview()
        }
    }
    
}


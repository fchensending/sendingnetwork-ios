//
//  Common.swift
//  ZuJuan
//
//  Created by ch on 2021/10/18.
//

import UIKit
import Foundation


func pointer(for any: AnyObject) -> String {
    "\(Unmanaged<AnyObject>.passUnretained(any).toOpaque())"
}

@discardableResult
func AddGCDTimer(timeout: Int = 60,
                 handler: @escaping (_ time: Int) -> (),
                 success: @escaping () -> ()) -> DispatchSourceTimer {
    var timeout = timeout
    let timer = DispatchSource.makeTimerSource(flags: [], queue: .global())
    timer.schedule(deadline: .now(), repeating: .seconds(1))
    timer.setEventHandler {
        DispatchQueue.main.async {
            handler(timeout)
            timeout -= 1
        }
        
        DispatchQueue.main.async {
            if timeout <= 0 {
                timer.cancel()
                success()
            }
        }
    }
    
    timer.setCancelHandler {
        DispatchQueue.main.async {}
    }
    
    timer.resume()
    return timer
}

func AddGCDTimer(timeout: Int = 30,
                 completion: @escaping () -> ()) {
    var timeout = timeout
    let timer = DispatchSource.makeTimerSource(flags: [], queue: .global())
    timer.schedule(deadline: .now(), repeating: .seconds(1))
    timer.setEventHandler {
        DispatchQueue.main.async {
            timeout -= 1
            if timeout <= 0 {
                timer.cancel()
                completion()
            }
        }
    }
    
    timer.setCancelHandler {
        DispatchQueue.main.async {}
    }
    
    timer.resume()
}

@discardableResult
func GCDTimer(interval: DispatchTimeInterval = .seconds(60),
              handler: @escaping () -> ()) -> DispatchSourceTimer {
    let timer = DispatchSource.makeTimerSource(queue: .global())
    timer.schedule(deadline: .now(), repeating: interval)
    timer.setEventHandler {
        handler()
    }
    timer.resume()
    return timer
}

struct Ratio {
    static let width = .screenWidth / 375.0
    
    static let height = .screenHeight / 667.0
    
    static let height_no_nav = (.screenHeight - .navStatusBarHeight) / (667.0 - .navStatusBarHeight)
}

//
//  Mems.swift
//  Mems
//
//  Created by MJ Lee on 2019/6/22.
//  Copyright © 2019 MJ Lee. All rights reserved.
//  https://github.com/CoderMJLee/Mems

import Foundation

public enum MemAlign : Int {
    case one = 1, two = 2, four = 4, eight = 8
}

private let _EMPTY_PTR = UnsafeRawPointer(bitPattern: 0x1)!

public struct Mems<T> {
    private static func _memStr(_ ptr: UnsafeRawPointer,
                                _ size: Int,
                                _ aligment: Int) ->String {
        if ptr == _EMPTY_PTR { return "" }
        
        var rawPtr = ptr
        var string = ""
        let fmt = "0x%0\(aligment << 1)lx"
        let count = size / aligment
        for i in 0..<count {
            if i > 0 {
                string.append(" ")
                rawPtr += aligment
            }
            let value: CVarArg
            switch aligment {
            case MemAlign.eight.rawValue:
                value = rawPtr.load(as: UInt64.self)
            case MemAlign.four.rawValue:
                value = rawPtr.load(as: UInt32.self)
            case MemAlign.two.rawValue:
                value = rawPtr.load(as: UInt16.self)
            default:
                value = rawPtr.load(as: UInt8.self)
            }
            string.append(String(format: fmt, value))
        }
        return string
    }
    
    private static func _memBytes(_ ptr: UnsafeRawPointer,
                                  _ size: Int) -> [UInt8] {
        var arr: [UInt8] = []
        if ptr == _EMPTY_PTR { return arr }
        for i in 0..<size {
            arr.append((ptr + i).load(as: UInt8.self))
        }
        return arr
    }
    
    public static func memBytes(ofVal v: inout T) -> [UInt8] {
        return _memBytes(ptr(ofVal: &v), MemoryLayout.stride(ofValue: v))
    }
    
    public static func memBytes(ofRef v: T) -> [UInt8] {
        let p = ptr(ofRef: v)
        return _memBytes(p, malloc_size(p))
    }
    

    public static func memStr(ofVal v: inout T, alignment: MemAlign? = nil) -> String {
        let p = ptr(ofVal: &v)
        return _memStr(p, MemoryLayout.stride(ofValue: v),
                       alignment != nil ? alignment!.rawValue : MemoryLayout.alignment(ofValue: v))
    }
    

    public static func memStr(ofRef v: T, alignment: MemAlign? = nil) -> String {
        let p = ptr(ofRef: v)
        return _memStr(p, malloc_size(p),
                       alignment != nil ? alignment!.rawValue : MemoryLayout.alignment(ofValue: v))
    }
    
    public static func ptr(ofVal v: inout T) -> UnsafeRawPointer {
        return MemoryLayout.size(ofValue: v) == 0 ? _EMPTY_PTR : withUnsafePointer(to: &v) {
            UnsafeRawPointer($0)
        }
    }
    
    public static func ptr(ofRef v: T) -> UnsafeRawPointer {
        if v is Array<Any>
            || Swift.type(of: v) is AnyClass
            || v is AnyClass {
            return UnsafeRawPointer(bitPattern: unsafeBitCast(v, to: UInt.self))!
        } else if v is String {
            var mstr = v as! String
            if mstr.mems.type() != .heap {
                return _EMPTY_PTR
            }
            return UnsafeRawPointer(bitPattern: unsafeBitCast(v, to: (UInt, UInt).self).1)!
        } else {
            return _EMPTY_PTR
        }
    }
    
    public static func size(ofVal v: inout T) -> Int {
        return MemoryLayout.size(ofValue: v) > 0 ? MemoryLayout.stride(ofValue: v) : 0
    }
    
    public static func size(ofRef v: T) -> Int {
        return malloc_size(ptr(ofRef: v))
    }
}

public enum MemsType : UInt8 {
    case text = 0xd0
    case tagPtr = 0xe0
    case heap = 0xf0
    case unknow = 0xff
}

public struct MemsWrapper<Base> {
    public private(set) var base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol MemsCompatible {}
public extension MemsCompatible {
    static var mems: MemsWrapper<Self>.Type {
        get { return MemsWrapper<Self>.self }
        set {}
    }
    var mems: MemsWrapper<Self> {
        get { return MemsWrapper(self) }
        set {}
    }
}

extension String: MemsCompatible {}
public extension MemsWrapper where Base == String {
    mutating func type() -> MemsType {
        let ptr = Mems.ptr(ofVal: &base)
        return MemsType(rawValue: (ptr + 15).load(as: UInt8.self) & 0xf0)
            ?? MemsType(rawValue: (ptr + 7).load(as: UInt8.self) & 0xf0)
            ?? .unknow
    }
}


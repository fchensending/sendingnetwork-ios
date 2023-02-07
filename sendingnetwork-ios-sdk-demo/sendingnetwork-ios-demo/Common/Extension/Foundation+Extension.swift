//
//  Foundation+Extension.swift
//  ZuJuan
//
//  Created by ch on 2021/9/22.
//

import UIKit
import Foundation

extension Optional where Wrapped == String {
    
    var isEmpty: Bool {
        switch self {
        case .none:
            return true
        case .some(let value):
            return value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    var isValidPhone: Bool {
        switch self {
        case .none:
            return false
        case .some(let value):
            return value.isValidPhone
        }
    }
    
    var isValidPassword: Bool {
        switch self {
        case .none:
            return false
        case .some(let value):
            return value.isValidPassword
        }
    }
    
    var isValidUsername: Bool {
        switch self {
        case .none:
            return false
        case .some(let value):
            return value.isValidUsername
        }
    }
    
    func contains(_ element: Wrapped) -> Bool {
        switch self {
        case .none:
            return false
        case .some(let value):
            return value.contains(element)
        }
    }
    
    /// +
    static func + (lhs: Wrapped?, rhs: Wrapped?) -> Wrapped? {
        switch (lhs, rhs) {
        case (.none, .none):
            return nil
        case (.some(let left), .none):
            return left
        case (.none, .some(let right)):
            return right
        case (.some(let left), .some(let right)):
            return left + right
        }
    }
    
}

extension Optional where Wrapped: Collection {
    
    var isEmpty: Bool {
        switch self {
        case .none:
            return true
        case .some(let value):
            return value.isEmpty
        }
    }
    
    var count: Int {
        switch self {
        case .none:
            return 0
        case .some(let value):
            return value.count
        }
    }
    
    var isNotEmpty: Bool {
        !isEmpty
    }
    
}

extension Optional where Wrapped: Comparable {

    static func > (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
        guard let lhs = lhs, let rhs = rhs else { return false }
        return lhs > rhs
    }
    
    static func >= (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
        guard let lhs = lhs, let rhs = rhs else { return false }
        return lhs >= rhs
    }
    
    static func < (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
        guard let lhs = lhs, let rhs = rhs else { return false }
        return lhs < rhs
    }
    
    static func <= (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
        guard let lhs = lhs, let rhs = rhs else { return false }
        return lhs <= rhs
    }
    
}

extension Array {
    
    /// creat unequal Element
    /// Array(repeating: Element, count: Int)
    /// @inlinable public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> [Element]
    /// func map<T>(_ transform: (Element) throws -> T) rethrows -> [T]
    init(_ count: Int, repeating: (Int) -> Element) {
        self = (0..<count).map(repeating)
    }
    
    mutating func modifyForEach(_ body: (_ index: Index, _ element: inout Element) -> ()) {
        for index in indices {
            modifyElement(atIndex: index) { body(index, &$0) }
        }
    }

    mutating func modifyElement(atIndex index: Index, _ handle: (_ element: inout Element) -> ()) {
        var element = self[index]
        handle(&element)
        self[index] = element
    }
    
    func safe(at index: Int) -> Element? {
        if (0..<count).contains(index) {
            return self[index]
        } else {
            return nil
        }
    }
    
}

extension Array where Element : Hashable {

    ///
    var unique: [Element] {
        return Array(Set(self))
    }
    
}

extension Array where Element: Equatable {
    
    /// Remove Dublicates
    // Thanks to https://github.com/sairamkotha for improving the method
    var unique: [Element] {
        reduce([]){ $0.contains($1) ? $0 : $0 + [$1] }
    }
    
    ///  Remove Dublicates
    ///
    /// - Parameter elements: array of elements to check.
    /// - Returns: de_Duplicate array
    func deDuplicate() -> [Element] {
        var results = [Element]()
        self.forEach { (element) in
            if !results.contains(element) {
                results.append(element)
            }
        }
        
        return results
    }
    
    /// Remove Dublicates
    func filterDuplicate<E: Equatable>(_ filter: (Element) -> E) -> [Element] {
        var result = [Element]()
        for element in self {
            let key = filter(element)
            if !result.map( { filter($0) }).contains(key) {
                result.append(element)
            }
        }
        return result
    }
    
    /// Check if array contains an array of elements.
    ///
    /// - Parameter elements: array of elements to check.
    /// - Returns: true if array contains all given items.
    func contains(_ elements: [Element]) -> Bool {
        if elements.isEmpty { // elements array is empty
            return false
        }
        
        var found = true
        for element in elements {
            if !contains(element) {
                found = false
            }
        }
        return found
    }
    
    /// All indexes of specified item.
    ///
    /// - Parameter item: item to check.
    /// - Returns: an array with all indexes of the given item.
    func indexes(of item: Element) -> [Int] {
        var indexes: [Int] = []
        for index in 0..<self.count {
            if self[index] == item {
                indexes.append(index)
            }
        }
        return indexes
    }
    
    /// Remove all instances of an item from array.
    ///
    /// - Parameter item: item to remove.
    mutating func remove(_ item: Element) {
        self = filter { $0 != item }
    }
    
    /// Creates an array of elements split into groups the length of size.
    /// If array can’t be split evenly, the final chunk will be the remaining elements.
    ///
    /// - parameter array: to chunk
    /// - parameter size: size of each chunk
    /// - returns: array elements chunked
    func chunk(size: Int = 1) -> [[Element]] {
        var result = [[Element]]()
        var chunk = -1
        for (index, element) in self.enumerated() {
            if index % size == 0 {
                result.append([Element]())
                chunk += 1
            }
            result[chunk].append(element)
        }
        return result
    }
    
    /// modify an element in Array
    /// - Parameter element: element
    mutating func modify(_ element: Element) {
        guard let index = firstIndex(of: element) else {
            return
        }

        self[index] = element
    }
    
    mutating func modifyEach(_ handle: (_ index: Index, _  element: inout Element) -> ()) {
        for index in indices {
            var element = self[index]
            handle(index, &element)
            self[index] = element
        }
    }
}

extension Array where Element == Int {
    
    var joined: String {
        map { String($0) }.joined(separator: ",")
    }
    
}

extension String {
    
    var url: URL? {
        URL(string: self)
    }
    
    var intValue: Int? {
        Int(self)
    }
    
    var double: Double? {
        Double(self)
    }
    
    var interval: TimeInterval? {
        TimeInterval(self)
    }
    
    var range: NSRange {
        (self as NSString).range(of: self)
    }
    
    var date: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: self)
        return date
    }
    
    ///
    var isValidPhone: Bool {
        let regx = "^1[3-9]\\d{9}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regx)
        return predicate.evaluate(with: self)
    }
    
    // replace 4-7 with *
    var safePhone: String {
        if self.count >= 7 {
            return (self as NSString).replacingCharacters(in: NSRange(location: 3, length: 4), with: "****")
        }else{
            return self
        }
    }
    
    /// password
    /// size 6-20
    var isValidPassword: Bool {
        (6...20).contains(count)
    }
    
    var isValidPassword1: Bool {
        let regx = "^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,20}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regx)
        return predicate.evaluate(with: self)
    }
    
    var isValidPassword2: Bool {
        let regx = "^(?=.*[0-9].*)(?=.*[A-Z].*)(?=.*[a-z].*).{6,20}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regx)
        return predicate.evaluate(with: self)
    }
    
    var isValidUsername: Bool {
        count >= 6 || isValidPhone
    }
    
    /// Sting to AttributedString
    var html: NSMutableAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSMutableAttributedString(data: data, options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    
    var attributedText: NSMutableAttributedString? {
        guard let html = html else {
            return nil
        }
        
        // long with ...
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        let range = NSRange(location: 0, length: html.length)
        html.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        return html
    }
    
    func range(of searchString: String) -> NSRange {
        (self as NSString).range(of: searchString)
    }
    
    func date(format: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)
        return date
    }
    
    func mutiLineSize(font: UIFont?, width: CGFloat) -> CGSize {
        guard let font = font else { return .zero }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byCharWrapping
        paragraphStyle.alignment = .left
        
        let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle : paragraphStyle]
        let rect = (self as NSString).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return rect.size
    }
    
    func size(with font: UIFont?) -> CGSize {
        guard let font = font else { return .zero }
        return (self as NSString).size(withAttributes: [NSAttributedString.Key.font: font])
    }
    
    subscript (i:Int)->String{
        let startIndex = self.index(self.startIndex, offsetBy: i)
        let endIndex = self.index(startIndex, offsetBy: 1)
        return String(self[startIndex..<endIndex])
    }

    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(self.startIndex, offsetBy: r.upperBound)
            return String(self[startIndex..<endIndex])
        }
    }

    subscript (index:Int , length:Int) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: index)
            let endIndex = self.index(startIndex, offsetBy: length)
            return String(self[startIndex..<endIndex])
        }
    }

    func substring(to:Int) -> String{
        return self[0..<to]
    }

    func substring(from:Int) -> String{
        return self[from..<self.count]
    }
    

    func indexOf(character:Character) -> Int{
        guard let index = firstIndex(of: character) else { return -1 }
        return  self[..<index].count
    }
    
}

extension Data {
    
    var string: String? {
        String(data: self, encoding: .utf8)
    }
    
}

extension Bundle {
    /// Constants used in the `Bundle` extension.
    struct InfoDictionaryKey {
        /// Constant for `CFBundleVersion`.
        static let version = "CFBundleVersion"
        /// Constant for `CFBundleDisplayName`.
        static let displayName = "CFBundleDisplayName"
        /// Constant for `CFBundleShortVersionString`.
        static let shortVersionString = "CFBundleShortVersionString"
    }
    
    var build: String {
        object(forInfoDictionaryKey: InfoDictionaryKey.version) as? String ?? "1"
    }
    
    var version: String {
        object(forInfoDictionaryKey: InfoDictionaryKey.shortVersionString) as? String ?? "1.0"
    }
    
    var displayName: String{
        object(forInfoDictionaryKey: InfoDictionaryKey.displayName) as? String ?? ""
    }
    
}

// MARK: - Initializers
extension Date {
    
    /// Create a new date form calendar components.
    ///
    /// - Parameters:
    ///   - calendar: Calendar (default is current).
    ///   - timeZone: TimeZone (default is current).
    ///   - era: Era (default is current era).
    ///   - year: Year (default is current year).
    ///   - month: Month (default is current month).
    ///   - day: Day (default is today).
    ///   - hour: Hour (default is current hour).
    ///   - minute: Minute (default is current minute).
    ///   - second: Second (default is current second).
    ///   - nanosecond: Nanosecond (default is current nanosecond).
    init(
        calendar: Calendar? = Calendar.current,
        timeZone: TimeZone? = TimeZone.current,
        era: Int? = Date().era,
        year: Int? = Date().year,
        month: Int? = Date().month,
        day: Int? = Date().day,
        hour: Int? = Date().hour,
        minute: Int? = Date().minute,
        second: Int? = Date().second,
        nanosecond: Int? = Date().nanosecond) {
        
        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = timeZone
        components.era = era
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        components.nanosecond = nanosecond
        
        self = calendar?.date(from: components) ?? Date()
    }
    
    /// Create date object from ISO8601 string.
    ///
    /// - Parameter iso8601String: ISO8601 string of format (yyyy-MM-dd'T'HH:mm:ss.SSSZ).
    init(iso8601String: String) {
        // https://github.com/justinmakaila/NSDate-ISO-8601/blob/master/NSDateISO8601.swift
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        self = dateFormatter.date(from: iso8601String) ?? Date()
    }
    
    /// Create new date object from UNIX timestamp.
    ///
    /// - Parameter unixTimestamp: UNIX timestamp.
    init(unixTimestamp: Double) {
        self.init(timeIntervalSince1970: unixTimestamp)
    }
    
    /// date to string
    /// - Parameter dateFormat: dateFormat
    /// - Returns: string
    func format(_ dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
    
    /// Date by adding multiples of calendar component.
    ///
    /// - Parameters:
    ///   - component: component type.
    ///   - value: multiples of compnenets to add.
    /// - Returns: original date + multiples of compnenet added.
    func adding(_ component: Calendar.Component, value: Int) -> Date {
        switch component {
        case .second:
            return calendar.date(byAdding: .second, value: value, to: self) ?? self
        case .minute:
            return calendar.date(byAdding: .minute, value: value, to: self) ?? self
        case .hour:
            return calendar.date(byAdding: .hour, value: value, to: self) ?? self
        case .day:
            return calendar.date(byAdding: .day, value: value, to: self) ?? self
        case .weekOfYear, .weekOfMonth:
            return calendar.date(byAdding: .day, value: value * 7, to: self) ?? self
        case .month:
            return calendar.date(byAdding: .month, value: value, to: self) ?? self
        case .year:
            return calendar.date(byAdding: .year, value: value, to: self) ?? self
        default:
            return self
        }
    }
    
}

extension Date {
    
    /// User’s current calendar.
    var calendar: Calendar {
        Calendar.current
    }
    
    /// Era.
    var era: Int {
        calendar.component(.era, from: self)
    }
    
    /// Year.
    var year: Int {
        get {
            return calendar.component(.year, from: self)
        }
        set {
            self = Date(calendar: calendar, timeZone: timeZone, era: era, year: newValue, month: month, day: day, hour: hour, minute: minute, second: second, nanosecond: nanosecond)
        }
    }
    
    /// Quarter.
    var quarter: Int {
        return calendar.component(.quarter, from: self)
    }
    
    /// Month.
    var month: Int {
        get {
            return calendar.component(.month, from: self)
        }
        set {
            self = Date(calendar: calendar, timeZone: timeZone, era: era, year: year, month: newValue, day: day, hour: hour, minute: minute, second: second, nanosecond: nanosecond)
        }
    }
    
    /// Day.
    var day: Int {
        get {
            return calendar.component(.day, from: self)
        }
        set {
            self = Date(calendar: calendar, timeZone: timeZone, era: era, year: year, month: month, day: newValue, hour: hour, minute: minute, second: second, nanosecond: nanosecond)
        }
    }
    
    /// Hour.
    var hour: Int {
        get {
            return calendar.component(.hour, from: self)
        }
        set {
            self = Date(calendar: calendar, timeZone: timeZone, era: era, year: year, month: month, day: day, hour: newValue, minute: minute, second: second, nanosecond: nanosecond)
        }
    }
    
    /// Minutes.
    var minute: Int {
        get {
            return calendar.component(.minute, from: self)
        }
        set {
            self = Date(calendar: calendar, timeZone: timeZone, era: era, year: year, month: month, day: day, hour: hour, minute: newValue, second: second, nanosecond: nanosecond)
        }
    }
    
    /// Seconds.
    var second: Int {
        get {
            return calendar.component(.second, from: self)
        }
        set {
            self = Date(calendar: calendar, timeZone: timeZone, era: era, year: year, month: month, day: day, hour: hour, minute: minute, second: newValue, nanosecond: nanosecond)
        }
    }
    
    /// Nanoseconds.
    var nanosecond: Int {
        calendar.component(.nanosecond, from: self)
    }
    
    /// Time zone used by system.
    var timeZone: TimeZone {
        calendar.timeZone
    }
    
    /// UNIX timestamp from date.
    var unixTimestamp: Double {
        timeIntervalSince1970
    }
    
    /// timeStamp
    var timeStamp: Int {
        Int(timeIntervalSince1970)
    }
    
    /// Date is expire
    var isExpire: Bool {
        self < Date()
    }
    
    /// Date is about to expire
    var isAboutToExpired: Bool {
        self.adding(.minute, value: -5) <= Date()
    }
}

extension Optional where Wrapped == Date {

    var isExpire: Bool {
        switch self {
        case .none:
            return false
        case .some(let value):
            return value.isExpire
        }
    }
    
}

extension CALayer {
    
    /// CALayer -> UIImage
    var snapshot: UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    var borderUIColor: UIColor{
        get{
            return UIColor(cgColor: self.borderColor!)
        }
        set{
            self.borderColor = newValue.cgColor
        }
    }
    
}

extension NSObject {
    
    var pointer: String {
        String(format: "%p", self)
    }
    
    var className: String {
        String(describing: type(of: self))
    }
    
    class var className: String {
        String(describing: self)
    }
}

extension Int {
    
    ///
    var digit: Int {
        String(self).count
    }
    
    var string: String {
        String(self)
    }
    
    var numberFormat: String {
        let format = NumberFormatter()
        format.numberStyle = .spellOut
        format.locale = Locale(identifier: "zh_CN")
        return format.string(from: NSNumber(value: self)) ?? String(self)
    }
    
    var timeFormat: String {
        var sec: Int = 0, min: Int = 0, hour: Int = 0
        if self < 60 {
            return String(format: "00:%02d", self)
        } else if self < 60 * 60 {
            sec = self % 60
            min = self / 60
            return String(format: "%02d:%02d", min, sec)
        } else {
            sec = self % 60
            min = self / 60 % 60
            hour = self / 60 / 60
            return String(format: "%02d:%02d:%02d", hour, min, sec)
        }
    }
    
}

extension Double {
    
    var digit: Int {
        Int(self).digit
    }
    
    var isTimestamp: Bool {
        digit == 10 || digit == 13
    }
    
    var sinceNow: String {
        guard isTimestamp else {
            return ""
        }
        
        var temp = self
        if digit == 13 {
            temp /= 1000
        }
        
        // 
        let timeInterval = Int(Date().timeIntervalSince1970 - temp)

        switch timeInterval {
        case let temp where temp < 60 * 5:
            return "mine"
        case var minute where minute / 60 < 60:
            minute = minute / 60
            return String(format: "%d minute", minute)
        case var hour where hour / (60 * 60) < 24:
            hour = hour / (60 * 60)
            return String(format: "%d hour", hour)
        case var day where day / (60 * 60 * 24) < 30:
            day = day / (60 * 60 * 24)
            return String(format: "%d day", day)
        case var mounth where mounth / (60 * 60 * 24 * 30) < 12:
            mounth = mounth / (60 * 60 * 24 * 30)
            return String(format: "%d mounth", mounth)
        default:
            let year = timeInterval / (60 * 60 * 24 * 30 * 12)
            return String(format: "%d year", year)
        }

    }
    
}

extension Float {
    var prettyPrint: String {
        
        if ceil(self) == self{
            return "\(Int(self))"
        }else{
            let newFloat = self * 100
            let intValue = Int( newFloat.rounded() )
            let part1 = intValue / 100
            let part2 = intValue % 100
            return "\(part1).\(part2 >= 10 ? "\(part2)" : "0\(part2)" )"
        }
    }
    
}


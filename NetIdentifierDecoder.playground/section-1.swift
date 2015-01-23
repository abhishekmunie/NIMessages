// Playground - noun: a place where people can play

import Foundation

prefix operator / {}
prefix func / (pattern: String) -> NSRegularExpression? {
    var err: NSError?
    let regex = NSRegularExpression(pattern: pattern, options: nil, error: &err)
    return regex
}

let identifier: NSString = "Abhishek Munie<contact@abhishekmunie.com>(gdghfjfjfffjfy)"
var err: NSError?
if let regex = /"([^<]*)\\<([^>]*)\\>\\(([^>]*)\\)" {
    var r = NSRange(location: 0, length: identifier.length)
    let res = regex.matchesInString(identifier, options: nil, range: r)
    let res0 = res[0] as NSTextCheckingResult
    
    if res0.numberOfRanges == 4 {
        let i = identifier.substringWithRange(res0.rangeAtIndex(0))
        let name = identifier.substringWithRange(res0.rangeAtIndex(1))
        let identity = identifier.substringWithRange(res0.rangeAtIndex(2))
        let uuid = identifier.substringWithRange(res0.rangeAtIndex(3))
    }
}

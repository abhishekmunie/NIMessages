// Playground - noun: a place where people can play

import Foundation

let uuidRef = CFUUIDCreate(nil)
let uuidStringRef = CFUUIDCreateString(nil, uuidRef)
let str = uuidStringRef as String

let uuid = str[str.startIndex...advance(str.startIndex, 10, str.endIndex)]

uuid.dataUsingEncoding(NSUTF8StringEncoding)!.length

//CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);


let identity = "email:fdds@exmaple.com"
if identity[identity.startIndex...advance(identity.startIndex, 5, identity.endIndex)] == "email:" {
    let email = identity[advance(identity.startIndex, 6, identity.endIndex)..<identity.endIndex]
}

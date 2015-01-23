// Playground - noun: a place where people can play

import Foundation

let str = "Hello"

class NID: NSSecureCoding {
    
    var name: String
    var identity: String {
        didSet {
            self.hashValue = self.identity.hashValue
        }
    }
    var uuid: String
    
    private init(name: String, identity: String, uuid: String) {
        self.name = name
        self.identity = identity
        self.uuid = uuid
    }
    
    init(coder aDecoder: NSCoder) {
        aDe
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        
    }
    
    class func supportsSecureCoding() -> Bool { return true }
}


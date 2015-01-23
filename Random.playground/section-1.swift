// Playground - noun: a place where people can play

import Foundation

func random64Bits() -> UInt64? {
    let fp = fopen("/dev/random", "r")

    if fp == nil {
        perror("randgetter")
        return nil
    }

    var value: UInt64 = 0
    var i = 0
    var c: UInt64

    for var i = 0; i < sizeofValue(value); i++ {
        value <<= 8
        c = UInt64(fgetc(fp))
        value = value | c
    }
    fclose(fp)
    
    return value
}

func randomStringOfLength(length: Int) -> String? {
    let fp = fopen("/dev/random", "r")
    
    if fp == nil {
        perror("randgetter")
        return nil
    }
    
    var string = UnsafeMutablePointer<CChar>.alloc(length+1)
    var i = 0
    var c: Int32 = 65
    var pos = string
    
    for var i = 0; i < length; i++ {
        c = fgetc(fp)
//        pos.memory = CChar(c)
        pos = pos.advancedBy(1)
    }
    pos
    fclose(fp)
    
    pos.memory = 0
    
    return String.fromCString(string)
}

random64Bits()
randomStringOfLength(5)

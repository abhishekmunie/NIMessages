// Playground - noun: a place where people can play

import Foundation
import AddressBook

let email: NSString = "abhishekmunie@yahoo.co.in"
let c = CFIndex(kABEqualCaseInsensitive.value)

let AB = ABAddressBook.sharedAddressBook()
let personForEmail = ABPerson.searchElementForProperty(kABEmailProperty as String,
    label: nil,
    key: nil,
    value: email,
    comparison: c)
let peopleFound = AB.recordsMatchingSearchElement(personForEmail)
println(peopleFound)


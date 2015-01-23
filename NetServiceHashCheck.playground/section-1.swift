// Playground - noun: a place where people can play

import Foundation

let ns1 = NSNetService(domain: "",
    type: "_am0nimsgpeer._tcp.",
    name: "Simba",
    port: 0)
ns1.setTXTRecordData(NSNetService.dataFromTXTRecordDictionary([:]))
ns1.includesPeerToPeer = true
//ns1.delegate = self
ns1.publishWithOptions(NSNetServiceOptions.ListenForConnections)

ns1.hash

let ns2 = NSNetService(domain: "",
    type: "_am0nimsgpeer._tcp.",
    name: "Simba",
    port: 0)

ns2.hash

ns1 == ns2
ns1.hash == ns2.hash

let rns1 = NSNetService(domain: "",
    type: "_am0nimsgpeer._tcp.",
    name: "Simba")
rns1.hash

let rns2 = NSNetService(domain: "",
    type: "_am0nimsgpeer._tcp.",
    name: "Simba")

rns2.hash

rns1 == rns2
rns1.hash == rns2.hash




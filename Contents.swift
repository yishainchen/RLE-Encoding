//: Playground - noun: a place where people can play

import UIKit

extension NSData {
    public func compressRLE() -> NSData {
        let data = NSMutableData()
        if length > 0 {
            var ptr = UnsafePointer<UInt8>(bytes)
            let end = ptr + length
            
            while ptr < end {                        // 1
                var count = 0
                var byte = ptr.memory
                var next = byte
                
                while next == byte && ptr < end && count < 64 {   // 2
                    ptr = ptr.advancedBy(1)
                    next = ptr.memory
                    count += 1
                }
                
                if count > 1 || byte >= 192 {          // 3
                    var size = 191 + UInt8(count)
                    data.appendBytes(&size, length: 1)
                    data.appendBytes(&byte, length: 1)
                } else {                               // 4
                    data.appendBytes(&byte, length: 1)
                }
            }
        }
        return data
    }
}

let originalString = "aaaaabbbcdeeeeeeef"
let utf8 = originalString.dataUsingEncoding(NSUTF8StringEncoding)! // <61616161 61626262 63646565 65656565 6566>
let compressed = utf8.compressRLE() // <c461c262 6364c665 66>

extension NSData {
    public func decompressRLE() -> NSData {
        let data = NSMutableData()
        if length > 0 {
            var ptr = UnsafePointer<UInt8>(bytes)
            let end = ptr + length
            
            while ptr < end {
                var byte = ptr.memory                 // 1
                ptr = ptr.advancedBy(1)
                
                if byte < 192 {                       // 2
                    data.appendBytes(&byte, length: 1)
                    
                } else if ptr < end {                 // 3
                    var value = ptr.memory
                    ptr = ptr.advancedBy(1)
                    
                    for _ in 0 ..< byte - 191 {
                        data.appendBytes(&value, length: 1)
                    }
                }
            }
        }
        return data
    }
}

let decompressed = compressed.decompressRLE() // <61616161 61626262 63646565 65656565 6566>
let restoredString = String(data: decompressed, encoding: NSUTF8StringEncoding) // "aaaaabbbcdeeeeeeef"
originalString == restoredString // true
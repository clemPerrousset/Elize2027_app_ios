import CryptoKit
import Foundation
#if canImport(UIKit)
import UIKit
#endif

func getPhoneId() -> String {
    #if canImport(UIKit)
    let vendorId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    #else
    let vendorId = UUID().uuidString
    #endif
    return SHA256.hash(data: Data(vendorId.utf8))
        .map { String(format: "%02x", $0) }
        .joined()
}

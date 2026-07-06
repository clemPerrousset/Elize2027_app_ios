import CryptoKit
import Foundation

func generateHmacToken(phoneId: String, secret: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd"
    let message = "\(phoneId):\(formatter.string(from: .now))"
    let key = SymmetricKey(data: Data(secret.utf8))
    return HMAC<SHA256>.authenticationCode(for: Data(message.utf8), using: key)
        .map { String(format: "%02x", $0) }
        .joined()
}

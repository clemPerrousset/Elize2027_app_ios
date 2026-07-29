import CryptoKit
import Foundation
import Security

private let kKeychainService = "com.elisee2027.deviceid"
private let kKeychainAccount = "persistentDeviceId"

private func loadOrCreatePersistentDeviceId() -> String {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: kKeychainService,
        kSecAttrAccount as String: kKeychainAccount,
        kSecReturnData as String: true,
    ]
    var item: CFTypeRef?
    if SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
       let data = item as? Data, let existing = String(data: data, encoding: .utf8) {
        return existing
    }

    let newId = UUID().uuidString
    let addQuery: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: kKeychainService,
        kSecAttrAccount as String: kKeychainAccount,
        kSecValueData as String: Data(newId.utf8),
        kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
    ]
    SecItemAdd(addQuery as CFDictionary, nil)
    return newId
}

func getPhoneId() -> String {
    let deviceId = loadOrCreatePersistentDeviceId()
    return SHA256.hash(data: Data(deviceId.utf8))
        .map { String(format: "%02x", $0) }
        .joined()
}

import Foundation

internal class PassageKeychainService {
    
    private let service = Bundle.main.bundleIdentifier ?? "PassageKeychainService"
    
    @discardableResult
    internal func addString(key: String, value: String) -> Bool {
        let valueData = Data(value.utf8)
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecAttrSynchronizable as String: kCFBooleanFalse!,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked,
            kSecValueData as String: valueData
        ]
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        switch status {
        case errSecSuccess: return true
        case errSecDuplicateItem: return updateString(key: key, value: value)
        default:
            print("Failed to add item to keychain with error: \(status)")
            return false
        }
    }
    
    internal func getString(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(decoding: data, as: UTF8.self)
        } else {
            print("Failed to get item from keychain with error: \(status)")
            return nil
        }
    }

    @discardableResult
    internal func updateString(key: String, value: String) -> Bool {
        let valueData = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        let attributes: [String: Any] = [
            kSecValueData as String: valueData
        ]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        switch status {
        case errSecSuccess: return true
        default:
            print("Failed to update item in keychain with error: \(status)")
            return false
        }
    }
    
    @discardableResult
    internal func deleteString(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        switch status {
        case errSecSuccess: return true
        default:
            print("Failed to remove item from keychain with error: \(status)")
            return false
        }
    }
    
}

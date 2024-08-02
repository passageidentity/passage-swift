import Foundation

extension String {
    func decodeBase64UrlSafeString() -> Data? {
        var base64 = self
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        if base64.count % 4 != 0 {
            base64.append(
                String(repeating: "=", count: 4 - base64.count % 4)
            )
        }
        return Data(base64Encoded: base64)
    }
}

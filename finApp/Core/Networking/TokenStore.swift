import Foundation

final class TokenStore {
    static let shared = TokenStore()

    private let tokenKey = "authToken"

    private init() {}

    var token: String? {
        get { UserDefaults.standard.string(forKey: tokenKey) }
        set {
            if let newValue {
                UserDefaults.standard.set(newValue, forKey: tokenKey)
            } else {
                UserDefaults.standard.removeObject(forKey: tokenKey)
            }
        }
    }

    func clear() {
        token = nil
    }
}

import Foundation

public enum StorageKey: RawRepresentable, Hashable, Sendable {
  case username
  case authToken
  case custom(String)
  
  public init?(rawValue: String) {
    switch rawValue {
      case "username":
        self = .username
      case "authToken":
        self = .authToken
      default:
        self = .custom(rawValue)
    }
  }
  
  public var rawValue: String {
    switch self {
      case .username:
        return "username"
      case .authToken:
        return "authToken"
      case .custom(let key):
        return key
    }
  }
  
  public static func namespaced(_ key: String, namespace: String = "StorageKit") -> String {
    "\(namespace).\(key)"
  }
  
  public static func versioned(_ key: String, version: Int) -> String {
    "v\(version).\(key)"
  }
}

public final class StorageKit: @unchecked Sendable {
  public static let shared = StorageKit()
  
  public let userDefaults: UserDefaultsStorage
  public let keychain: KeychainStorage
  public let secure: SecureStorage
  
  public init(
    userDefaults: UserDefaultsStorage = UserDefaultsStorage(),
    keychain: KeychainStorage = KeychainStorage(),
    secure: SecureStorage? = nil
  ) {
    self.userDefaults = userDefaults
    self.keychain = keychain
    self.secure = secure ?? SecureStorage(keychainStorage: keychain)
  }
}

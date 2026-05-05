import Foundation
import Security

public protocol KeychainHelping {
  func save(data: Data, for key: String) -> Result<Void, StorageError>
  func fetchData(for key: String) -> Result<Data, StorageError>
  func deleteData(for key: String) -> Result<Void, StorageError>
}

public final class KeychainHelper: KeychainHelping {
  private let service: String
  private let accessGroup: String?
  
  public init(service: String = "com.storagekit.default", accessGroup: String? = nil) {
    self.service = service
    self.accessGroup = accessGroup
  }
  
  public func save(data: Data, for key: String) -> Result<Void, StorageError> {
    let query = baseQuery(for: key)
    
    let updateStatus = SecItemUpdate(
      query as CFDictionary,
      [kSecValueData as String: data] as CFDictionary
    )
    
    if updateStatus == errSecSuccess {
      return .success(())
    }
    
    if updateStatus != errSecItemNotFound {
      return .failure(.keychainError(status: updateStatus))
    }
    
    var addQuery = query
    addQuery[kSecValueData as String] = data
    
    let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
    guard addStatus == errSecSuccess else {
      return .failure(.keychainError(status: addStatus))
    }
    
    return .success(())
  }
  
  public func fetchData(for key: String) -> Result<Data, StorageError> {
    var query = baseQuery(for: key)
    query[kSecReturnData as String] = true
    query[kSecMatchLimit as String] = kSecMatchLimitOne
    
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    
    guard status != errSecItemNotFound else {
      return .failure(.dataNotFound)
    }
    
    guard status == errSecSuccess else {
      return .failure(.keychainError(status: status))
    }
    
    guard let data = result as? Data else {
      return .failure(.dataNotFound)
    }
    
    return .success(data)
  }
  
  public func deleteData(for key: String) -> Result<Void, StorageError> {
    let status = SecItemDelete(baseQuery(for: key) as CFDictionary)
    
    guard status == errSecSuccess || status == errSecItemNotFound else {
      return .failure(.keychainError(status: status))
    }
    
    return .success(())
  }
  
  private func baseQuery(for key: String) -> [String: Any] {
    var query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: key
    ]
    
    if let accessGroup {
      query[kSecAttrAccessGroup as String] = accessGroup
    }
    
    return query
  }
}

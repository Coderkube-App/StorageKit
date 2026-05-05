import Foundation

public enum StorageError: Error, LocalizedError, Equatable {
  case encodingFailed
  case decodingFailed
  case keychainError(status: OSStatus)
  case dataNotFound
  
  public var errorDescription: String? {
    switch self {
      case .encodingFailed:
        return "Failed to encode value for storage."
      case .decodingFailed:
        return "Failed to decode value from storage."
      case .keychainError(let status):
        return "Keychain operation failed with status: \(status)."
      case .dataNotFound:
        return "No data found for the requested key."
    }
  }
}

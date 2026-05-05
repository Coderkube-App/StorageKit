import Foundation

public protocol StorageProtocol {
  func save<T: Codable>(_ value: T, for key: String)
  func fetch<T: Codable>(_ type: T.Type, for key: String) -> T?
  func delete(for key: String)
}

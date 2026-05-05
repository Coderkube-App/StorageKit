import Foundation

public extension Decodable {
  static func fromData(_ data: Data) -> Self? {
    CodableStorage().decodeIfPossible(Self.self, from: data)
  }
}

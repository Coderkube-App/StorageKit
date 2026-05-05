import Foundation

public extension Encodable {
  func toData() -> Data? {
    CodableStorage().encodeIfPossible(self)
  }
}

import Foundation

public final class CodableStorage {
  private let encoder: JSONEncoder
  private let decoder: JSONDecoder
  
  public init(
    encoder: JSONEncoder = JSONEncoder(),
    decoder: JSONDecoder = JSONDecoder()
  ) {
    self.encoder = encoder
    self.decoder = decoder
  }
  
  public func encode<T: Encodable>(_ value: T) -> Result<Data, StorageError> {
    do {
      return .success(try encoder.encode(value))
    } catch {
      return .failure(.encodingFailed)
    }
  }
  
  public func decode<T: Decodable>(_ type: T.Type, from data: Data) -> Result<T, StorageError> {
    do {
      return .success(try decoder.decode(type, from: data))
    } catch {
      return .failure(.decodingFailed)
    }
  }
  
  public func encodeIfPossible<T: Encodable>(_ value: T) -> Data? {
    try? encoder.encode(value)
  }
  
  public func decodeIfPossible<T: Decodable>(_ type: T.Type, from data: Data) -> T? {
    try? decoder.decode(type, from: data)
  }
}

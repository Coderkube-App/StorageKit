# StorageKit

`StorageKit` is a reusable Swift Package that provides a clean, scalable, and production-ready storage abstraction for Apple platforms.

It supports:

- `UserDefaults` storage with `Codable`
- Keychain-backed secure storage
- Property wrappers for clean SwiftUI usage
- Key namespacing and versioned key migration
- Thread-safe access patterns and dependency injection

## Requirements

- iOS 15+
- macOS 12+
- Swift 6.2+

## Installation

### Swift Package Manager

In Xcode:

1. Go to **File > Add Packages...**
2. Enter your repository URL for `StorageKit`
3. Select the version/range and add the package

Or in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/StorageKit.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "StorageKit", package: "StorageKit")
        ]
    )
]
```

## Package Structure

```text
StorageKit/
 ├── Sources/StorageKit/
 │   ├── Core/
 │   ├── UserDefaults/
 │   ├── Keychain/
 │   ├── Secure/
 │   ├── Codable/
 │   ├── PropertyWrappers/
 │   ├── Extensions/
 │   └── StorageKit.swift
 ├── Tests/StorageKitTests/
 └── Package.swift
```

## Core API

### StorageProtocol

```swift
public protocol StorageProtocol {
    func save<T: Codable>(_ value: T, for key: String)
    func fetch<T: Codable>(_ type: T.Type, for key: String) -> T?
    func delete(for key: String)
}
```

### StorageKit Entry Point

```swift
StorageKit.shared.userDefaults.save("Vijay", for: "name")
let name: String? = StorageKit.shared.userDefaults.fetch(String.self, for: "name")
```

## Usage

### UserDefaults Storage

```swift
let defaults = StorageKit.shared.userDefaults
defaults.save(true, for: "isLoggedIn")
defaults.save(42, for: "launchCount")
defaults.save("Vijay", for: "username")

let isLoggedIn = defaults.fetch(Bool.self, for: "isLoggedIn")
let launchCount = defaults.fetch(Int.self, for: "launchCount")
let username = defaults.fetch(String.self, for: "username")
```

### Keychain Storage

```swift
let keychain = StorageKit.shared.keychain
keychain.save("token_abc123", for: "authToken")
let token = keychain.fetch(String.self, for: "authToken")
keychain.delete(for: "authToken")
```

### Secure Storage (Keychain + Optional Transformer + Cache)

```swift
let secure = StorageKit.shared.secure
secure.save("super_secret", for: "secretKey")
let value = secure.fetch(String.self, for: "secretKey")
```

### Property Wrappers (SwiftUI-Friendly)

```swift
import SwiftUI
import StorageKit

struct ContentView: View {
    @UserDefault(key: "username", defaultValue: "")
    private var username: String

    @SecureValue(key: "authToken")
    private var token: String?

    var body: some View {
        VStack {
            TextField("Username", text: $username)
            Button("Save Token") { token = "new_token" }
            Button("Clear Token") { token = nil }
        }
        .padding()
    }
}
```

## Namespacing and Versioned Keys

Use `StorageKey` helpers to keep keys organized:

```swift
let namespaced = StorageKey.namespaced("profile", namespace: "com.myapp")
let versioned = StorageKey.versioned("authToken", version: 2)
```

## Migration Support

```swift
let secure = StorageKit.shared.secure
secure.migrate([
    StorageMigration(
        fromKey: StorageKey.versioned("authToken", version: 1),
        toKey: StorageKey.versioned("authToken", version: 2)
    )
])
```

## Error Handling

`StorageError` provides shared error types:

- `encodingFailed`
- `decodingFailed`
- `keychainError(status:)`
- `dataNotFound`

## Testing

Run tests:

```bash
swift test
```

Current tests cover:

- Codable save/fetch/delete
- Primitive type support (`Bool`, `Int`, `String`)
- Keychain operations with mock helper
- Secure storage key migration

## Design Notes

- Protocol-driven architecture for flexibility
- Dependency injection support for testability
- Thread-safe implementation using synchronization queues and locks
- No force unwraps in library code paths

## License

Add your preferred license here (MIT, Apache-2.0, etc.).

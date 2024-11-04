import Foundation

/// A simple, counter-based timestamp that includes a UUID that is used as a "tie-breaker" when two instances have the same count value.
struct Timestamp: Codable, Comparable, Hashable, Identifiable, Sendable {
    let count: UInt64
    let id: UUID
    
    init() {
        self.count = 0
        self.id = .init()
    }
    
    init(count: UInt64, id: UUID) {
        self.count = count
        self.id = id
    }
    
    func tick() -> Self {
        .init(count: self.count + 1, id: self.id)
    }
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.count, lhs.id) < (rhs.count, rhs.id)
    }
}

extension Timestamp: CustomDebugStringConvertible {
    var debugDescription: String {
        "Timestamp { \(count), \(id.uuidString.prefix(2))..\(id.uuidString.suffix(2)) }"
    }
}

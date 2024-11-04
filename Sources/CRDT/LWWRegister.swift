/// A "last writer wins" implementation of a CRDT.
/// The wrapped type is atomicly tracked and replaced by the instance with the most recent timestamp when merged together.
public struct LWWRegister<T>: CRDT {
    /// The wrapped value in this "last writer wins" CRDT.
    /// Mutating this value causes the timestamp to be updated.
    public var value: T {
        get { state.value }
        set { state = .init(value: newValue, timestamp: state.timestamp.tick()) }
    }

    struct State {
        let value: T
        let timestamp: Timestamp
    }
    private(set) var state: State
    
    /// Wraps a value in a new instance with a timestamp that defaults to "zero".
    public init(value: T) {
        self.state = .init(value: value, timestamp: .init())
    }
    
    // MARK: CRDT Conformance
    
    public func merged(with other: Self) -> Self {
        self.state.timestamp > other.state.timestamp ? self : other
    }
}

extension LWWRegister.State: Codable where T: Codable {}
extension LWWRegister: Codable where T: Codable {}

extension LWWRegister.State: Equatable where T: Equatable {}
extension LWWRegister: Equatable where T: Equatable {}

extension LWWRegister.State: Hashable where T: Hashable {}
extension LWWRegister: Hashable where T: Hashable {}

extension LWWRegister: Identifiable where T: Identifiable {
    public var id: T.ID { value.id }
}

extension LWWRegister.State: Sendable where T: Sendable {}
extension LWWRegister: Sendable where T: Sendable {}

extension LWWRegister: ExpressibleByFloatLiteral where T == FloatLiteralType {
    public init(floatLiteral value: FloatLiteralType) {
        self.init(value: value)
    }
}
extension LWWRegister: ExpressibleByIntegerLiteral where T == IntegerLiteralType {
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value: value)
    }
}
extension LWWRegister: ExpressibleByBooleanLiteral where T == BooleanLiteralType {
    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(value: value)
    }
}
extension LWWRegister: ExpressibleByStringLiteral where T == StringLiteralType {
    public init(stringLiteral value: StringLiteralType) {
        self.init(value: value)
    }
}
extension LWWRegister: ExpressibleByUnicodeScalarLiteral where T == StringLiteralType {
    public init(unicodeScalarLiteral value: String) {
        self.init(value: value)
    }
}
extension LWWRegister: ExpressibleByExtendedGraphemeClusterLiteral where T == StringLiteralType {
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(value: value)
    }
}

extension LWWRegister: CustomDebugStringConvertible {
    public var debugDescription: String {
        "LWWRegister<\(T.self)> { \(state.value), \(state.timestamp) }"
    }
}

// MARK: - Unit tests

import SwiftUI
import UnitTestingPreviews

public struct LWWRegisterTests: TestCase, View {
    public init() {}
    public static nonisolated var tests: some TestSpec {
        Test(title: "Basics") { 
            var sut = LWWRegister(value: 1)
            AssertEqual(sut.state.value, 1)
            AssertEqual(sut.state.timestamp.count, 0)
            AssertEqual(sut.value, 1)
            
            sut.value += 10
            AssertEqual(sut.state.value, 11)
            AssertEqual(sut.state.timestamp.count, 1)
            AssertEqual(sut.value, 11)
        }
        
        Test(title: "Merge Principles") {
            let a = LWWRegister(value: "a")
            var b = a
            b.value = "b"
            var c = b
            c.value = "c"
            
            AssertGreaterThan(b.state.timestamp, a.state.timestamp)
            AssertGreaterThan(c.state.timestamp, b.state.timestamp)
            
            // Commutative
            var sut1 = a.merged(with: b)
            var sut2 = b.merged(with: a)
            AssertEqual(sut1, sut2)
            
            // Associative
            sut1 = (a.merged(with: b)).merged(with: c)
            sut2 = a.merged(with: b.merged(with: c))
            AssertEqual(sut1, sut2)
            
            // Idempotent
            sut1 = a.merged(with: a)
            AssertEqual(sut1, a)
        }
        
        Test(title: "Expressibility") {
            let floatSut: LWWRegister = 3.14
            AssertEqual(floatSut.value, 3.14)
            
            let intSut: LWWRegister = 1
            AssertEqual(intSut.value, 1)
            
            let boolSut: LWWRegister = false
            AssertEqual(boolSut.value, false)
            
            let stringSut: LWWRegister = "Hello, world"
            AssertEqual(stringSut.value, "Hello, world")
        }
    }
}
#Preview {
    LWWRegisterTests()
}

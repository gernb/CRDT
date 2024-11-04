/// A conflict-free replicated data type.
/// A CRDT can be synchronised with another instance in a peer-to-peer transaction without the need of a server/client relationship.
public protocol CRDT {
    /// Combines two instances to create a new, merged instance.
    /// A properly implemented merge function must follow 3 principles that guarantee the basic promise of a "conflict-free replicated data type":
    /// 1. Commutative: when merging two instances, the order doesn't matter. `A.merged(with: B) == B.merged(with: A)`
    /// 2. Associative: when merging three or more instances, the order of pairing doesn't matter. `A.merged(with: B.merged(with: C)) == (A.merged(with: B)).merged(with: C)`
    /// 3. Idempotent: merging an instance with itself is a "no-op". `A.merged(with: A) == A`
    func merged(with other: Self) -> Self
}

public extension CRDT {
    /// Updates an instance by merging it with another instance.
    mutating func merge(with other: Self) {
        self = merged(with: other)
    }
}

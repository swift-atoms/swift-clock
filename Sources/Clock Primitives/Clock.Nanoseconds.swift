extension Clock {

    public struct Nanoseconds: InstantProtocol, Sendable, Hashable, Comparable {

        public let rawValue: UInt64

        @inlinable
        public init(_ rawValue: UInt64) { self.rawValue = rawValue }
    }
}

extension Clock.Nanoseconds {

    public typealias Duration = Swift.Duration

    @inlinable
    public func advanced(by duration: Swift.Duration) -> Self {
        let (seconds, attoseconds) = duration.components
        let nanos = seconds * 1_000_000_000 + attoseconds / 1_000_000_000
        return Self(rawValue &+ UInt64(bitPattern: nanos))
    }

    @inlinable
    public func duration(to other: Self) -> Swift.Duration {

        let diff = Int64(bitPattern: other.rawValue &- rawValue)
        return .nanoseconds(diff)
    }

    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

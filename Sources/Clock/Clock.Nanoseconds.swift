extension Clock {

    public struct Nanoseconds: Sendable, Hashable {

        public let rawValue: UInt64

        @inlinable
        public init(_ rawValue: UInt64) { self.rawValue = rawValue }
    }
}

extension Clock.Nanoseconds {

    public typealias Duration = Swift.Duration

    @inlinable
    public func advanced(by duration: Swift.Duration) -> Self {
        let nanoseconds = duration.attoseconds / 1_000_000_000
        return Self(rawValue &+ UInt64(truncatingIfNeeded: nanoseconds))
    }

    @inlinable
    public func duration(to other: Self) -> Swift.Duration {
        let difference = Int128(other.rawValue) - Int128(rawValue)
        return Swift.Duration(attoseconds: difference * 1_000_000_000)
    }

    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

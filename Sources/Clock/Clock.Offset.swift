extension Clock {

    public struct Offset: InstantProtocol, Sendable, Hashable, Comparable {

        public let rawValue: Swift.Duration

        @inlinable
        public init(_ rawValue: Swift.Duration = .zero) { self.rawValue = rawValue }
    }
}

extension Clock.Offset {

    public typealias Duration = Swift.Duration

    @inlinable
    public func advanced(by duration: Swift.Duration) -> Self {
        Self(rawValue + duration)
    }

    @inlinable
    public func duration(to other: Self) -> Swift.Duration {
        other.rawValue - rawValue
    }

    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

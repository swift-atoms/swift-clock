public import Tagged

extension Tagged: @retroactive InstantProtocol where Underlying: InstantProtocol {

    public typealias Duration = Underlying.Duration

    @inlinable
    public func advanced(by duration: Underlying.Duration) -> Self {
        Self(_unchecked: underlying.advanced(by: duration))
    }

    @inlinable
    public func duration(to other: Self) -> Underlying.Duration {
        underlying.duration(to: other.underlying)
    }
}

extension Tagged where Underlying: InstantProtocol, Underlying.Duration == Swift.Duration {

    @inlinable
    public static func + (lhs: Self, rhs: Swift.Duration) -> Self {
        Self(_unchecked: lhs.underlying.advanced(by: rhs))
    }

    @inlinable
    public static func + (lhs: Swift.Duration, rhs: Self) -> Self {
        Self(_unchecked: rhs.underlying.advanced(by: lhs))
    }

    @inlinable
    public static func += (lhs: inout Self, rhs: Swift.Duration) {
        lhs = lhs + rhs
    }

    @inlinable
    public static func - (lhs: Self, rhs: Swift.Duration) -> Self {
        Self(_unchecked: lhs.underlying.advanced(by: .zero - rhs))
    }

    @inlinable
    public static func -= (lhs: inout Self, rhs: Swift.Duration) {
        lhs = lhs - rhs
    }

    @inlinable
    public static func - (lhs: Self, rhs: Self) -> Swift.Duration {
        rhs.underlying.duration(to: lhs.underlying)
    }
}

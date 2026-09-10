extension Clock {

    public enum Deadline<Instant> {
        case at(Instant)
        case never
    }
}
extension Clock.Deadline {
    @inlinable public init(_ instant: Instant) { self = .at(instant) }
    @inlinable public var instant: Instant? {
        switch self {
        case .at(let instant): instant
        case .never: nil
        }
    }
}
extension Clock.Deadline: Sendable where Instant: Sendable {}
extension Clock.Deadline: Equatable where Instant: Equatable {}
extension Clock.Deadline: Hashable where Instant: Hashable {}

extension Clock.Deadline where Instant: Comparable {
    @inlinable public func hasExpired(at instant: Instant) -> Bool {
        switch self {
        case .at(let deadline): instant >= deadline
        case .never: false
        }
    }
}
extension Clock.Deadline: Comparable where Instant: Comparable {
    @inlinable public static func < (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.at(let lhs), .at(let rhs)): lhs < rhs
        case (.at, .never): true
        case (.never, _): false
        }
    }
}
extension Clock.Deadline where Instant: Swift.InstantProtocol {
    public typealias Duration = Instant.Duration

    @inlinable public static func after(_ duration: Duration, from instant: Instant) -> Self {
        .at(instant.advanced(by: duration))
    }
    @inlinable public func remaining(at instant: Instant) -> Duration? {
        switch self {
        case .at(let deadline):
            instant < deadline ? instant.duration(to: deadline) : .zero
        case .never: nil
        }
    }
}

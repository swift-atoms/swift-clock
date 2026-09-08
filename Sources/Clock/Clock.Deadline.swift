extension Clock {
    /// A finite deadline on one timeline, or an explicit absence of expiration.
    ///
    /// Works with any instant model conforming to `Swift.InstantProtocol`.
    /// No finite coordinate is reserved as an infinity sentinel.
    public enum Deadline<Instant: Swift.InstantProtocol>: Sendable, Hashable {
        case at(Instant)
        case never
    }
}

extension Clock.Deadline {
    public typealias Duration = Instant.Duration

    @inlinable
    public init(_ instant: Instant) {
        self = .at(instant)
    }

    /// Constructs a finite deadline using the instant's own arithmetic contract.
    /// Overflow is not converted to `.never`.
    @inlinable
    public static func after(_ duration: Duration, from instant: Instant) -> Self {
        .at(instant.advanced(by: duration))
    }

    /// The finite position, or `nil` for `.never`.
    @inlinable
    public var instant: Instant? {
        switch self {
        case .at(let instant): instant
        case .never: nil
        }
    }

    @inlinable
    public func hasExpired(at instant: Instant) -> Bool {
        switch self {
        case .at(let deadline): instant >= deadline
        case .never: false
        }
    }

    /// The nonnegative time remaining, or `nil` for `.never`.
    /// A finite difference follows the instant's representability contract.
    @inlinable
    public func remaining(at instant: Instant) -> Duration? {
        switch self {
        case .at(let deadline):
            instant < deadline ? instant.duration(to: deadline) : .zero
        case .never:
            nil
        }
    }
}

extension Clock.Deadline: Swift.Comparable {
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.at(let lhs), .at(let rhs)): lhs < rhs
        case (.at, .never): true
        case (.never, _): false
        }
    }
}

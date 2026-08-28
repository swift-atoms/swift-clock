public import Tagged

extension Clock.Continuous {

    public struct Deadline: Sendable, Hashable {

        public let instant: Clock.Continuous.Instant

        @inlinable
        public init(_ instant: Clock.Continuous.Instant) {
            self.instant = instant
        }
    }
}

extension Clock.Continuous.Deadline {

    @inlinable
    public static var never: Self {
        Self(Clock.Continuous.Instant(nanoseconds: .max))
    }

    @inlinable
    public static func now(at instant: Clock.Continuous.Instant) -> Self {
        Self(instant)
    }

    @inlinable
    public static func after(
        _ duration: Duration,
        from instant: Clock.Continuous.Instant
    ) -> Self {
        let currentNs = instant.nanoseconds
        let (seconds, attoseconds) = duration.components
        let (secNanos, overflowMul) = seconds.multipliedReportingOverflow(by: 1_000_000_000)
        if overflowMul {
            return seconds > 0 ? .never : Self(Clock.Continuous.Instant(nanoseconds: 0))
        }
        let totalNanos = secNanos &+ (attoseconds / 1_000_000_000)
        guard totalNanos >= 0 else {
            let absNs = UInt64(-totalNanos)
            let subtracted = currentNs &- absNs
            return Self(
                Clock.Continuous.Instant(nanoseconds: subtracted > currentNs ? 0 : subtracted)
            )
        }
        let added = currentNs &+ UInt64(totalNanos)
        return Self(
            Clock.Continuous.Instant(nanoseconds: added < currentNs ? .max : added)
        )
    }
}

extension Clock.Continuous.Deadline: Comparable {

    @inlinable
    public static func < (lhs: Clock.Continuous.Deadline, rhs: Clock.Continuous.Deadline) -> Bool {
        lhs.instant < rhs.instant
    }
}

extension Clock.Continuous.Deadline {

    @inlinable
    public func hasExpired(at instant: Clock.Continuous.Instant) -> Bool {
        instant >= self.instant
    }

    @inlinable
    public func remaining(at instant: Clock.Continuous.Instant) -> Duration {
        self.instant > instant ? instant.duration(to: self.instant) : .zero
    }
}

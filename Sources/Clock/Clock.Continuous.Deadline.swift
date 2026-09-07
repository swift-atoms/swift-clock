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
        let nanoseconds = duration.attoseconds / 1_000_000_000
        let result = Int128(instant.nanoseconds) + nanoseconds
        return Self(Clock.Continuous.Instant(nanoseconds: UInt64(clamping: result)))
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

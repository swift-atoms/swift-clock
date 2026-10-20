#if !hasFeature(Embedded)
    public import Tagged
    public import Time

    extension Clock {
        public struct Unimplemented: _Concurrency.Clock, Sendable {
            public init() {}
        }
    }

    extension Clock.Unimplemented {
        public typealias Instant = Tagged<Self, Time.Instant>

        public var now: Instant { .init(Time.Instant(secondsSinceUnixEpoch: 0)) }

        public var minimumResolution: Duration { .zero }

        nonisolated(nonsending)
            public func sleep(
                until deadline: Instant,
                tolerance: Duration? = nil
            ) async throws
        {
            preconditionFailure(
                """
                Unimplemented clock sleep was invoked. This indicates a code path \
                that was not expected to use time-based functionality.
                """
            )
        }
    }
#endif

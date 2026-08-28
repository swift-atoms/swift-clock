public import Tagged

extension Clock {

    public struct Suspending: Sendable {

        public init() {}
    }
}

extension Clock.Suspending {

    public typealias Duration = Swift.Duration

    public typealias Instant = Tagged<Self, Clock.Nanoseconds>

    public var minimumResolution: Duration { .nanoseconds(1) }
}

public import Tagged

extension Clock {

    public struct Continuous: Sendable {

        public init() {}

    }
}

extension Clock.Continuous {

    public typealias Duration = Swift.Duration

    public typealias Instant = Tagged<Self, Clock.Nanoseconds>

    public var minimumResolution: Duration { .nanoseconds(1) }
}

public import Tagged
public import Time

extension Clock {

    public struct Continuous: Sendable {
        @inlinable
        public init() {}
    }
}

extension Clock.Continuous {
    public typealias Duration = Swift.Duration
    public typealias Instant = Clock.Instant<Self>
    public typealias Deadline = Clock.Deadline<Instant>
}

public import Tagged
public import Time

extension Clock {

    public struct Suspending: Sendable {
        @inlinable
        public init() {}
    }
}

extension Clock.Suspending {
    public typealias Duration = Swift.Duration
    public typealias Instant = Clock.Instant<Self>
    public typealias Deadline = Clock.Deadline<Instant>
}

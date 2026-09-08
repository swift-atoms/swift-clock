public import Tagged
public import Time

extension Clock {
    /// The domain of a clock that stops advancing during system suspension.
    /// A platform implementation supplies its reference, readings, and resolution.
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

public import Tagged
public import Time
public import _Concurrency

extension Clock {

    /// A clock whose time and timers come from a host.
    ///
    /// For a program that runs on a host's event loop and has no clock of its own, such as one in a browser page.
    /// `elapsed` answers how long the host has been running; `schedule` asks the host to call a closure back after
    /// a duration. A sleep that is cancelled wakes when its timer fires, not before, and then throws.
    public final class Hosted: _Concurrency.Clock, Sendable {
        private let elapsed: @Sendable () -> Duration
        private let schedule: @Sendable (Duration, @escaping @Sendable () -> Void) -> Void

        public init(
            elapsed: @escaping @Sendable () -> Duration,
            schedule: @escaping @Sendable (Duration, @escaping @Sendable () -> Void) -> Void
        ) {
            self.elapsed = elapsed
            self.schedule = schedule
        }
    }
}

extension Clock.Hosted {
    public typealias Instant = Tagged<Clock.Hosted, Time.Instant>

    public var now: Instant {
        Instant(Time.Instant(secondsSinceUnixEpoch: 0)).advanced(by: elapsed())
    }

    nonisolated(nonsending)
        public func sleep(
            until deadline: Instant,
            tolerance: Duration? = nil
        ) async throws(CancellationError)
    {
        if Task.isCancelled { throw CancellationError() }
        let delay = now.duration(to: deadline)
        if delay > .zero {
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                schedule(delay) { continuation.resume() }
            }
        }
        if Task.isCancelled { throw CancellationError() }
    }
}

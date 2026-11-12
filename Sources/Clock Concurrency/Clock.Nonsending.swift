public import _Concurrency

extension Clock {
    /// A clock that sleeps on the caller's actor rather than hopping off it.
    ///
    /// `_Concurrency.Clock.sleep` leaves the caller's isolation, so code that wakes from it reaches its next line
    /// at some later turn of its actor, and a test cannot tell when. A sleep through this protocol is told the
    /// caller's actor, which lets ``Clock/Test`` resume a sleeper on that actor and wait until it sleeps again or
    /// returns, so a test that advances the clock observes every effect of the wake-up.
    ///
    /// The shape is Point-Free's `NonsendingClock` (swift-clocks 2), and its requirement is the one pitched for
    /// `_Concurrency.Clock` itself ("[pre-pitch] Nonisolated nonsending Clock protocol", Swift Forums, October
    /// 2026). When the standard library's `Clock` has it, this protocol goes.
    public protocol Nonsending<Duration>: _Concurrency.Clock {
        func sleep(
            until deadline: Instant,
            tolerance: Instant.Duration?,
            isolation: isolated (any Actor)?
        ) async throws
    }
}

extension Clock.Nonsending {
    public func sleep(
        until deadline: Instant,
        tolerance: Instant.Duration?,
        isolation: isolated (any Actor)? = #isolation
    ) async throws {
        try await sleep(until: deadline, tolerance: tolerance)
    }

    public func sleep(for duration: Duration, tolerance: Instant.Duration? = nil) async throws {
        try await sleep(until: now.advanced(by: duration), tolerance: tolerance, isolation: #isolation)
    }
}

#if !hasFeature(Embedded)
    extension Swift.ContinuousClock: Clock.Nonsending {}

    extension Swift.SuspendingClock: Clock.Nonsending {}
#endif

extension Clock.Nonsending {
    /// Zero: a clock that states no resolution of its own.
    public var minimumResolution: Instant.Duration { .zero }
}

extension Clock.Hosted: Clock.Nonsending {}

extension Clock.Immediate: Clock.Nonsending {}

extension Clock.Unimplemented: Clock.Nonsending {}

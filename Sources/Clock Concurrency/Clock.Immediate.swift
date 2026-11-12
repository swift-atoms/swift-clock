import Synchronization
public import Tagged
public import Time
public import _Concurrency

extension Clock {
    public final class Immediate: _Concurrency::Clock, Sendable {
        private let state: Mutex<State>

        public init(now: Instant = .init(Time.Instant(secondsSinceUnixEpoch: 0))) {
            self.state = Mutex(State(now: now, minimumResolution: .zero))
        }
    }
}

extension Clock.Immediate {
    public typealias Instant = Tagged<Clock.Immediate, Time.Instant>

    public var now: Instant {
        state.withLock { $0.now }
    }

    public var minimumResolution: Duration {
        get { state.withLock { $0.minimumResolution } }
        set { state.withLock { $0.minimumResolution = newValue } }
    }

    nonisolated(nonsending)
        public func sleep(
            until deadline: Instant,
            tolerance: Duration? = nil
        ) async throws
    {
        if Task.isCancelled { throw CancellationError() }
        state.withLock { state in
            if state.now < deadline {
                state.now = deadline
            }
        }
    }
}

extension Clock.Immediate {
    fileprivate struct State: Sendable {
        var now: Instant
        var minimumResolution: Duration
    }
}

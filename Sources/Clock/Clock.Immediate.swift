public import Tagged

#if !hasFeature(Embedded)

    import Synchronization

    extension Clock {

        public final class Immediate: _Concurrency.Clock, @unsafe @unchecked Sendable {
            private let state: Mutex<State>

            public init(now: Instant = .init()) {
                self.state = Mutex(State(now: now, minimumResolution: .zero))
            }
        }
    }

    extension Clock.Immediate {

        public typealias Instant = Tagged<Clock.Immediate, Clock.Offset>

        private struct State: Sendable {
            var now: Instant
            var minimumResolution: Duration
        }
    }

    extension Clock.Immediate {

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

            try Task.checkCancellation()
            state.withLock { $0.now = deadline }
        }
    }

#endif

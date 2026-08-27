public import Tagged

#if !hasFeature(Embedded)

    import Synchronization

    extension Clock {

        public final class Test: _Concurrency.Clock, @unsafe @unchecked Sendable {
            private let state: Mutex<State>

            public init(now: Instant = .init()) {
                self.state = Mutex(
                    State(
                        now: now,
                        minimumResolution: .zero,
                        nextID: 0,
                        suspensions: []
                    )
                )
            }
        }
    }

    extension Clock.Test {

        public typealias Instant = Tagged<Clock.Test, Clock.Offset>

        fileprivate struct State: Sendable {
            var now: Instant
            var minimumResolution: Duration
            var nextID: UInt64
            var suspensions: [Entry]
        }
    }

    extension Clock.Test.State {
        struct Entry: Sendable {
            let id: UInt64
            let deadline: Clock.Test.Instant
            let continuation: CheckedContinuation<Void, Never>
        }
    }

    extension Clock.Test {

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

            let id = state.withLock { st -> UInt64 in
                let id = st.nextID
                st.nextID &+= 1
                return id
            }

            await withTaskCancellationHandler(
                operation: {
                    await withCheckedContinuation {
                        (continuation: CheckedContinuation<Void, Never>) in
                        let resumeImmediately = state.withLock { st -> Bool in
                            guard !Task.isCancelled, st.now < deadline else { return true }
                            st.suspensions.append(
                                State.Entry(
                                    id: id,
                                    deadline: deadline,
                                    continuation: continuation
                                )
                            )
                            return false
                        }
                        if resumeImmediately {
                            continuation.resume()
                        }
                    }
                },
                onCancel: {
                    let toResume: CheckedContinuation<Void, Never>? = state.withLock { st in
                        guard let index = st.suspensions.firstIndex(where: { $0.id == id }) else {
                            return nil
                        }
                        return st.suspensions.remove(at: index).continuation
                    }
                    toResume?.resume()
                },
                isolation: #isolation
            )

            try Task.checkCancellation()
        }

        public func advance(by duration: Duration = .zero) {

            let toResume: [CheckedContinuation<Void, Never>] = state.withLock { st in
                let deadline = st.now.advanced(by: duration)
                st.now = deadline
                st.suspensions.sort { $0.deadline < $1.deadline }
                var ready: [CheckedContinuation<Void, Never>] = []
                while let head = st.suspensions.first, head.deadline <= deadline {
                    ready.append(head.continuation)
                    st.suspensions.removeFirst()
                }
                return ready
            }
            for c in toResume { c.resume() }
        }

        public func advance(to deadline: Instant) {
            let toResume: [CheckedContinuation<Void, Never>] = state.withLock { st in
                st.now = deadline
                st.suspensions.sort { $0.deadline < $1.deadline }
                var ready: [CheckedContinuation<Void, Never>] = []
                while let head = st.suspensions.first, head.deadline <= deadline {
                    ready.append(head.continuation)
                    st.suspensions.removeFirst()
                }
                return ready
            }
            for c in toResume { c.resume() }
        }

        public func run() {
            let toResume: [CheckedContinuation<Void, Never>] = state.withLock { st in
                st.suspensions.sort { $0.deadline < $1.deadline }
                if let last = st.suspensions.last { st.now = last.deadline }
                let all = st.suspensions.map(\.continuation)
                st.suspensions.removeAll()
                return all
            }
            for c in toResume { c.resume() }
        }

        public func checkSuspension() throws(Suspension.Error) {
            let hasActive = state.withLock { !$0.suspensions.isEmpty }
            guard !hasActive else {
                throw Suspension.Error()
            }
        }
    }

    extension Clock.Test {

        public enum Suspension {}
    }

    extension Clock.Test.Suspension {

        public struct Error: Swift.Error, Sendable {}
    }

#endif

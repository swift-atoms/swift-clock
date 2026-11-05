#if !hasFeature(Embedded)
    import Synchronization
    public import Tagged
    public import Time

    extension Clock {
        /// A clock whose time moves only when a test moves it, as Point-Free's `TestClock` (swift-clocks 2).
        ///
        /// A sleep remembers the actor it was called from. Advancing the clock resumes each sleep that is due, in
        /// deadline order, on that actor, and waits until the sleeper has run up to its next suspension: another
        /// sleep, or the end of its work. When `advance` returns, every effect of the wake-up has landed, however the
        /// tasks involved are scheduled. A sleep from a nonisolated context has no actor to wait on, so it cannot be
        /// tested deterministically and stops the program.
        public final class Test: Clock.Nonsending, Sendable {
            private let state: Mutex<State>

            public init(now: Instant = .init(Time.Instant(secondsSinceUnixEpoch: 0))) {
                self.state = Mutex(
                    State(
                        now: now,
                        minimumResolution: .zero,
                        nextID: 0,
                        suspensions: [],
                        advancements: [:]
                    )
                )
            }
        }
    }

    extension Clock.Test {
        public typealias Instant = Tagged<Clock.Test, Time.Instant>

        fileprivate struct State: Sendable {
            var now: Instant
            var minimumResolution: Duration
            var nextID: UInt64
            var suspensions: [Entry]
            /// The advances waiting for a woken sleep to return, keyed by that sleep's id.
            var advancements: [UInt64: CheckedContinuation<Void, Never>]
        }
    }

    extension Clock.Test.State {
        struct Entry: Sendable {
            let id: UInt64
            let deadline: Clock.Test.Instant
            let isolation: any Actor
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
            try await sleep(until: deadline, tolerance: tolerance, isolation: #isolation)
        }

        /// Sleeps until the clock reaches `deadline`, remembering `isolation` to resume on.
        ///
        /// `isolation` is checked, not bound with `guard let`: with Swift 6.4.2 a sleep that binds its isolated
        /// parameter to a local no longer resumes on that actor, and its advance then returns before the sleeper ran.
        public func sleep(
            until deadline: Instant,
            tolerance: Duration?,
            isolation: isolated (any Actor)?
        ) async throws {
            try Task.checkCancellation()
            guard isolation != nil else {
                preconditionFailure(
                    """
                    'Clock.Test' cannot sleep in nonisolated contexts because it cannot be deterministically \
                    tested. Call 'sleep' from actor-isolated code.
                    """
                )
            }

            let id = state.withLock { state -> UInt64 in
                let id = state.nextID
                state.nextID &+= 1
                return id
            }
            defer {
                let advancement = state.withLock { $0.advancements.removeValue(forKey: id) }
                advancement?.resume()
            }

            await withTaskCancellationHandler(
                operation: {
                    await withCheckedContinuation {
                        (continuation: CheckedContinuation<Void, Never>) in
                        let resumeImmediately = state.withLock { state -> Bool in
                            guard !Task.isCancelled, deadline > state.now else { return true }
                            state.suspensions.append(
                                State.Entry(
                                    id: id,
                                    deadline: deadline,
                                    isolation: isolation!,
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
                    let toResume: CheckedContinuation<Void, Never>? = state.withLock { state in
                        guard let index = state.suspensions.firstIndex(where: { $0.id == id })
                        else {
                            return nil
                        }
                        return state.suspensions.remove(at: index).continuation
                    }
                    toResume?.resume()
                },
                isolation: isolation
            )

            try Task.checkCancellation()
        }

        /// Moves the clock forward by `duration`, waking each sleep due by then (see ``Clock/Test``).
        public func advance(by duration: Duration = .zero) async {
            precondition(duration >= .zero, "A test clock cannot move backwards")
            await advance(to: now.advanced(by: duration))
        }

        /// Moves the clock forward to `deadline`, waking each sleep due by then (see ``Clock/Test``).
        public func advance(to deadline: Instant) async {
            while let entry = state.withLock({ state -> State.Entry? in
                precondition(deadline >= state.now, "A test clock cannot move backwards")
                guard
                    let index = state.suspensions.indices.min(by: {
                        (state.suspensions[$0].deadline, state.suspensions[$0].id)
                            < (state.suspensions[$1].deadline, state.suspensions[$1].id)
                    }),
                    state.suspensions[index].deadline <= deadline
                else {
                    state.now = deadline
                    return nil
                }
                state.now = state.suspensions[index].deadline
                return state.suspensions.remove(at: index)
            }) {
                await entry.isolation.run { _ in await self.wake(entry) }
            }
        }

        /// Advances the clock until no sleep is pending, including the sleeps that woken work starts.
        ///
        /// Work that sleeps forever keeps this from returning.
        public func run() async {
            while let deadline = state.withLock({ $0.suspensions.map(\.deadline).min() }) {
                await advance(to: deadline)
            }
        }

        public func checkSuspension() throws(Suspension.Error) {
            let hasActive = state.withLock { !$0.suspensions.isEmpty }
            guard !hasActive else {
                throw Suspension.Error()
            }
        }

        /// Resumes `entry` and returns once its sleep has returned. It runs on the sleeper's actor, so that is once the
        /// sleeper has suspended again or finished, since it holds the actor until then.
        private func wake(_ entry: State.Entry) async {
            await withCheckedContinuation { (advancement: CheckedContinuation<Void, Never>) in
                state.withLock { $0.advancements[entry.id] = advancement }
                entry.continuation.resume()
            }
        }
    }

    extension Clock.Test {
        public enum Suspension {}
    }

    extension Clock.Test.Suspension {
        public struct Error: Swift.Error, Sendable {}
    }

    extension Actor {
        fileprivate func run(_ operation: @Sendable (isolated Self) async -> Void) async {
            await operation(self)
        }
    }
#endif

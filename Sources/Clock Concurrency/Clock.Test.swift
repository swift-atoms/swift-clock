#if !hasFeature(Embedded)
import Synchronization
public import Tagged
public import Time

extension Clock {
    public final class Test: _Concurrency.Clock, Sendable {
        private let state: Mutex<State>

        public init(now: Instant = .init(Time.Instant(secondsSinceUnixEpoch: 0))) {
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
    public typealias Instant = Tagged<Clock.Test, Time.Instant>

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
    ) async throws {
        try Task.checkCancellation()

        let id = state.withLock { state -> UInt64 in
            let id = state.nextID
            state.nextID &+= 1
            return id
        }

        await withTaskCancellationHandler(
            operation: {
                await withCheckedContinuation {
                    (continuation: CheckedContinuation<Void, Never>) in
                    let resumeImmediately = state.withLock { state -> Bool in
                        guard !Task.isCancelled, state.now < deadline else { return true }
                        state.suspensions.append(
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
                let toResume: CheckedContinuation<Void, Never>? = state.withLock { state in
                    guard let index = state.suspensions.firstIndex(where: { $0.id == id }) else {
                        return nil
                    }
                    return state.suspensions.remove(at: index).continuation
                }
                toResume?.resume()
            },
            isolation: #isolation
        )

        try Task.checkCancellation()
    }

    public func advance(by duration: Duration = .zero) {
        precondition(duration >= .zero, "A test clock cannot move backwards")

        let toResume: [CheckedContinuation<Void, Never>] = state.withLock { state in
            let deadline = state.now.advanced(by: duration)
            state.now = deadline
            state.suspensions.sort { $0.deadline < $1.deadline }
            var ready: [CheckedContinuation<Void, Never>] = []
            while let head = state.suspensions.first, head.deadline <= deadline {
                ready.append(head.continuation)
                state.suspensions.removeFirst()
            }
            return ready
        }
        for continuation in toResume {
            continuation.resume()
        }
    }

    public func advance(to deadline: Instant) {
        let toResume: [CheckedContinuation<Void, Never>] = state.withLock { state in
            precondition(deadline >= state.now, "A test clock cannot move backwards")
            state.now = deadline
            state.suspensions.sort { $0.deadline < $1.deadline }
            var ready: [CheckedContinuation<Void, Never>] = []
            while let head = state.suspensions.first, head.deadline <= deadline {
                ready.append(head.continuation)
                state.suspensions.removeFirst()
            }
            return ready
        }
        for continuation in toResume {
            continuation.resume()
        }
    }

    public func run() {
        let toResume: [CheckedContinuation<Void, Never>] = state.withLock { state in
            state.suspensions.sort { $0.deadline < $1.deadline }
            if let last = state.suspensions.last, last.deadline > state.now {
                state.now = last.deadline
            }
            let all = state.suspensions.map(\.continuation)
            state.suspensions.removeAll()
            return all
        }
        for continuation in toResume {
            continuation.resume()
        }
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

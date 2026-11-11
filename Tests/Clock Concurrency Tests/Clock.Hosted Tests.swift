import Clock_Concurrency
import Synchronization
import Testing

enum `Clock.Hosted Tests` {}

extension `Clock.Hosted Tests` {
    final class Host: Sendable {
        let elapsed = Mutex(Duration.zero)
        let timers = Mutex<[(delay: Duration, fire: @Sendable () -> Void)]>([])
        let scheduled: AsyncStream<Void>
        let continuation: AsyncStream<Void>.Continuation

        init() {
            (scheduled, continuation) = AsyncStream<Void>.makeStream()
        }

        var clock: Clock.Hosted {
            Clock.Hosted(
                elapsed: { self.elapsed.withLock { $0 } },
                schedule: { delay, fire in
                    self.timers.withLock { $0.append((delay, fire)) }
                    self.continuation.yield()
                }
            )
        }
    }
}

extension `Clock.Hosted Tests` {
    @Suite
    struct Test {
        @Test
        func `now follows the host's elapsed time`() {
            let host = Host()
            let clock = host.clock
            let start = clock.now

            host.elapsed.withLock { $0 = .seconds(3) }

            #expect(start.duration(to: clock.now) == .seconds(3))
        }

        @Test
        func `a sleep asks the host for a timer of the remaining time and wakes when it fires`() async throws {
            let host = Host()
            let clock = host.clock
            let woke = Mutex(false)

            let task = Task {
                try await clock.sleep(for: .seconds(5))
                woke.withLock { $0 = true }
            }
            for await _ in host.scheduled { break }

            let timers = host.timers.withLock { $0 }
            #expect(timers.count == 1)
            #expect(timers.first?.delay == .seconds(5))
            #expect(!woke.withLock { $0 })

            host.elapsed.withLock { $0 = .seconds(5) }
            timers.first?.fire()
            try await task.value

            #expect(woke.withLock { $0 })
        }

        @Test
        func `a deadline that has passed returns without a timer`() async throws {
            let host = Host()
            let clock = host.clock
            let deadline = clock.now

            host.elapsed.withLock { $0 = .seconds(1) }
            try await clock.sleep(until: deadline)

            #expect(host.timers.withLock { $0.isEmpty })
        }

        @Test
        func `a cancelled sleep throws once its timer fires`() async {
            let host = Host()
            let clock = host.clock

            let task = Task {
                try await clock.sleep(for: .seconds(5))
            }
            for await _ in host.scheduled { break }
            task.cancel()
            host.timers.withLock { $0 }.first?.fire()

            let result = await task.result
            #expect(throws: CancellationError.self) { try result.get() }
        }
    }
}

import Clock_Concurrency
import Testing

@Suite
struct `Clock.Test` {
    enum Reach: CaseIterable, Sendable {
        case direct, existential, erased
    }

    @MainActor
    @Test(arguments: Reach.allCases)
    func `advancing runs each woken sleeper on its actor until it sleeps again`(_ reach: Reach) async {
        for _ in 0..<100 {
            let test = Clock.Test()
            let ticks = Ticks()
            let task: Task<Void, any Swift.Error>
            switch reach {
            case .direct:
                task = Task.immediate { @MainActor in
                    for _ in 0..<3 {
                        try await test.sleep(for: .milliseconds(140))
                        ticks.count += 1
                    }
                }
            case .existential, .erased:
                let clock: any Clock.Nonsending<Duration> = reach == .erased ? Clock.`Any`(test) : test
                task = Task.immediate { @MainActor in
                    for _ in 0..<3 {
                        try await clock.sleep(for: .milliseconds(140))
                        ticks.count += 1
                    }
                }
            }
            await test.advance(by: .milliseconds(140))
            #expect(ticks.count == 1)
            await test.advance(by: .milliseconds(140))
            #expect(ticks.count == 2)
            await test.run()
            #expect(ticks.count == 3)
            task.cancel()
        }
    }

    @MainActor
    @Test
    func `a sleep until now returns at once`() async throws {
        let test = Clock.Test()
        let ticks = Ticks()
        let task = Task.immediate { @MainActor in
            try await test.sleep(until: test.now)
            ticks.count += 1
        }
        #expect(ticks.count == 1)
        #expect(throws: Never.self) { try test.checkSuspension() }
        task.cancel()
        _ = await task.result
    }
}

@MainActor
final class Ticks {
    var count = 0
}

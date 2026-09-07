import Clock
import Testing

@Suite struct `Nanosecond clocks preserve their numeric boundaries` {
    @Test(arguments: [UInt64(0), 1, UInt64(Int64.max), UInt64(Int64.max) + 1, UInt64.max])
    func `elapsed durations agree with ordering over the full coordinate range`(rawValue: UInt64) {
        let first = Clock.Nanoseconds(0)
        let last = Clock.Nanoseconds(rawValue)
        let expected = Duration(attoseconds: Int128(rawValue) * 1_000_000_000)
        #expect(first.duration(to: last) == expected)
        #expect(last.duration(to: first) == .zero - expected)
        #expect(first.advanced(by: expected) == last)
        #expect(last.advanced(by: .zero - expected) == first)
        #expect((first < last) == (first.duration(to: last) > .zero))
    }

    @Test(arguments: [Int128.min, Int128.min + 1, -1, 0, 1, Int128.max])
    func `advancing accepts the full native duration range with wrapping coordinates`(attoseconds: Int128) {
        let duration = Duration(attoseconds: attoseconds)
        let origin = Clock.Nanoseconds(17)
        let advanced = origin.advanced(by: duration)
        let modulus = Int128(UInt64.max) + 1
        let remainder = (17 + attoseconds / 1_000_000_000) % modulus
        let expected = UInt64(remainder < 0 ? remainder + modulus : remainder)
        #expect(advanced.rawValue == expected)
    }

    @Test(arguments: [Int64(-1_999_999_999), -999_999_999, 0, 999_999_999, 1_999_999_999])
    func `nanosecond projection truncates fractional nanoseconds toward zero`(attoseconds: Int64) {
        let duration = Duration(secondsComponent: 0, attosecondsComponent: attoseconds)
        let origin = Clock.Nanoseconds(10)
        #expect(origin.advanced(by: duration).rawValue == UInt64(10 + attoseconds / 1_000_000_000))
    }

    @Test func `tagged clock families retain full unsigned endpoint distances`() {
        let continuous = Clock.Continuous.Instant(nanoseconds: 0)
        let suspending = Clock.Suspending.Instant(nanoseconds: 0)
        let expected = Duration(attoseconds: Int128(UInt64.max) * 1_000_000_000)
        #expect(continuous.duration(to: .init(nanoseconds: .max)) == expected)
        #expect(suspending.duration(to: .init(nanoseconds: .max)) == expected)
    }
}

@Suite struct `Continuous deadlines saturate at coordinate bounds` {
    @Test func `positive displacements beyond signed nanoseconds remain finite when representable`() {
        let origin = Clock.Continuous.Instant(nanoseconds: 0)
        let duration = Duration(secondsComponent: 9_223_372_036, attosecondsComponent: 900_000_000_000_000_000)
        #expect(Clock.Continuous.Deadline.after(duration, from: origin).instant.nanoseconds == 9_223_372_036_900_000_000)
        #expect(Clock.Continuous.Deadline.after(.seconds(10_000_000_000), from: origin).instant.nanoseconds == 10_000_000_000_000_000_000)
    }

    @Test func `negative displacements beyond signed nanoseconds preserve representable results`() {
        let origin = Clock.Continuous.Instant(nanoseconds: .max)
        let duration = Duration(attoseconds: -Int128(UInt64(Int64.max) + 1) * 1_000_000_000)
        #expect(Clock.Continuous.Deadline.after(duration, from: origin).instant.nanoseconds == UInt64(Int64.max))
        #expect(Clock.Continuous.Deadline.after(.seconds(-10_000_000_000), from: origin).instant.nanoseconds == 8_446_744_073_709_551_615)
    }

    @Test func `unrepresentable deadlines saturate for the entire native duration range`() {
        let origin = Clock.Continuous.Instant(nanoseconds: 123)
        #expect(Clock.Continuous.Deadline.after(Duration(attoseconds: .max), from: origin) == .never)
        #expect(Clock.Continuous.Deadline.after(Duration(attoseconds: .min), from: origin).instant.nanoseconds == 0)
        #expect(Clock.Continuous.Deadline.after(.nanoseconds(-124), from: origin).instant.nanoseconds == 0)
        #expect(Clock.Continuous.Deadline.after(.nanoseconds(1), from: .init(nanoseconds: .max)) == .never)
    }

    @Test func `remaining duration preserves the full unsigned nanosecond distance`() {
        let origin = Clock.Continuous.Instant(nanoseconds: 0)
        let deadline = Clock.Continuous.Deadline(.init(nanoseconds: UInt64.max - 1))
        #expect(deadline.remaining(at: origin).attoseconds == Int128(UInt64.max - 1) * 1_000_000_000)
        #expect(!deadline.hasExpired(at: origin))
        #expect(deadline.hasExpired(at: deadline.instant))
        #expect(deadline.remaining(at: deadline.instant) == .zero)
        #expect(deadline.remaining(at: .init(nanoseconds: .max)) == .zero)
    }

    @Test func `next deadline retains its established never sentinel`() {
        let next = Clock.Continuous.Deadline.Next()
        #expect(next.value == nil)
        let deadline = Clock.Continuous.Deadline(.init(nanoseconds: UInt64.max - 1))
        next.store(deadline)
        #expect(next.value == deadline)
        next.store(.never)
        #expect(next.value == nil)
    }
}

import Carrier
import Clock
import Clock
import Carrier
import Testing

private func carriedValue<C: Carrier.`Protocol`>(_ carrier: C) -> C.Underlying
where C: Copyable, C.Underlying: Copyable {
    carrier.underlying
}

@Suite
struct `Clock Carrier Tests` {

    @Test
    func `nanoseconds is a self carrier`() {
        let instant = Clock.Nanoseconds(1_000)

        #expect(carriedValue(instant) == instant)
        #expect(Clock.Nanoseconds(instant) == instant)
    }

    @Test
    func `offset is a self carrier`() {
        let instant = Clock.Offset(.milliseconds(250))

        #expect(carriedValue(instant) == instant)
        #expect(Clock.Offset(instant) == instant)
    }
}

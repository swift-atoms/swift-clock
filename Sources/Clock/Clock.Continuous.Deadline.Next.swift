import Synchronization

extension Clock.Continuous.Deadline {

    public final class Next: Sendable {
        let _value: Atomic<UInt64>

        public init() {
            self._value = Atomic(UInt64.max)
        }
    }
}

extension Clock.Continuous.Deadline.Next {

    public func store(_ deadline: Clock.Continuous.Deadline) {
        _value.store(deadline.instant.nanoseconds, ordering: .releasing)
    }

    public var value: Clock.Continuous.Deadline? {
        let ns = _value.load(ordering: .acquiring)
        guard ns != .max else { return nil }
        return Clock.Continuous.Deadline(Clock.Continuous.Instant(nanoseconds: ns))
    }
}

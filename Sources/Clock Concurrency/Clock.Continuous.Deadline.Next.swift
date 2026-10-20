#if !hasFeature(Embedded)
import Synchronization

extension Clock.Continuous.Deadline {
    public final class Next: Sendable {
        private let valueStorage: Atomic<UInt64>

        public init() {
            self.valueStorage = Atomic(UInt64.max)
        }

        public func store(_ deadline: Clock.Continuous.Deadline) {
            valueStorage.store(
                deadline.instant.map { instant in
                    let (seconds, attoseconds) = instant.offset.components
                    return UInt64(clamping: seconds) &* 1_000_000_000 &+ UInt64(clamping: attoseconds / 1_000_000_000)
                } ?? .max,
                ordering: .releasing
            )
        }

        public var value: Clock.Continuous.Deadline? {
            let nanoseconds = valueStorage.load(ordering: .acquiring)
            guard nanoseconds != .max else { return nil }
            return Clock.Continuous.Deadline(
                Clock.Continuous.Instant(offset: .nanoseconds(nanoseconds))
            )
        }
    }
}
#endif

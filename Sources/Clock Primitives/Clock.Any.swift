#if !hasFeature(Embedded)

    extension Clock {

        public struct `Any`<D: DurationProtocol & Hashable>: _Concurrency.Clock, @unchecked Sendable
        {

            public struct Instant: InstantProtocol, Sendable {
                fileprivate let _box: Box
            }

            private let _now: @Sendable () -> Instant
            private let _minimumResolution: @Sendable () -> D

            private let _sleep: nonisolated(nonsending) @Sendable (Instant, D?) async throws -> Void

            public var now: Instant { _now() }

            public var minimumResolution: D { _minimumResolution() }

            public init<C: _Concurrency.Clock>(_ clock: C)
            where C.Duration == D, C: Sendable, C.Instant: Sendable {
                self._now = {
                    Instant(_box: ConcreteBox(clock.now))
                }
                self._minimumResolution = { clock.minimumResolution }
                self._sleep = { deadline, tolerance in
                    guard let box = deadline._box as? ConcreteBox<C.Instant, D> else {
                        preconditionFailure("Mismatched clock instant types")
                    }
                    try await clock.sleep(until: box.instant, tolerance: tolerance)
                }
            }

            nonisolated(nonsending)
                public func sleep(
                    until deadline: Instant,
                    tolerance: D? = nil
                ) async throws
            {

                try await _sleep(deadline, tolerance)
            }
        }
    }

    extension Clock.`Any`.Instant {

        public func advanced(by duration: D) -> Self {
            Self(_box: _box.advanced(by: duration))
        }

        public func duration(to other: Self) -> D {
            _box.duration(to: other._box)
        }

        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs._box.compare(lhs._box, rhs._box)
        }

        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs._box.equals(lhs._box, rhs._box)
        }

        public func hash(into hasher: inout Hasher) {
            _box.hash(into: &hasher)
        }

        fileprivate class Box: @unchecked Sendable {
            func advanced(by duration: D) -> Box { fatalError("Must be overridden") }
            func duration(to other: Box) -> D { fatalError("Must be overridden") }
            func compare(_ lhs: Box, _ rhs: Box) -> Bool { fatalError("Must be overridden") }
            func equals(_ lhs: Box, _ rhs: Box) -> Bool { fatalError("Must be overridden") }
            func hash(into hasher: inout Hasher) { fatalError("Must be overridden") }
        }
    }

    private final class ConcreteBox<
        I: InstantProtocol & Hashable & Sendable,
        D: DurationProtocol & Hashable
    >: Clock.`Any`<D>.Instant.Box where I.Duration == D {

        let instant: I

        init(_ instant: I) {
            self.instant = instant
        }

        override func advanced(by duration: D) -> Clock.`Any`<D>.Instant.Box {
            ConcreteBox(instant.advanced(by: duration))
        }

        override func duration(to other: Clock.`Any`<D>.Instant.Box) -> D {
            guard let other = other as? ConcreteBox<I, D> else {
                preconditionFailure("Mismatched clock instant types")
            }
            return instant.duration(to: other.instant)
        }

        override func compare(
            _ lhs: Clock.`Any`<D>.Instant.Box,
            _ rhs: Clock.`Any`<D>.Instant.Box
        ) -> Bool {
            guard let lhs = lhs as? ConcreteBox<I, D>, let rhs = rhs as? ConcreteBox<I, D> else {
                preconditionFailure("Mismatched clock instant types")
            }
            return lhs.instant < rhs.instant
        }

        override func equals(
            _ lhs: Clock.`Any`<D>.Instant.Box,
            _ rhs: Clock.`Any`<D>.Instant.Box
        ) -> Bool {
            guard let lhs = lhs as? ConcreteBox<I, D>, let rhs = rhs as? ConcreteBox<I, D> else {
                preconditionFailure("Mismatched clock instant types")
            }
            return lhs.instant == rhs.instant
        }

        override func hash(into hasher: inout Hasher) {
            hasher.combine(instant)
        }
    }

#endif

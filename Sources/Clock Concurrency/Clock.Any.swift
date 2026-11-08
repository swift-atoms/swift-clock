#if !hasFeature(Embedded)
    extension Clock {
        public struct `Any`<D: DurationProtocol & Hashable>: Clock.Nonsending, Sendable {
            private let _now: @Sendable () -> Instant
            private let _minimumResolution: @Sendable () -> D
            private let _sleep: @Sendable (Instant, D?, isolated (any Actor)?) async throws -> Void

            /// Wraps `clock`, whose sleeps keep the caller's actor (``Clock/Nonsending``).
            public init<C: Clock.Nonsending>(_ clock: C)
            where C.Duration == D, C: Sendable, C.Instant: Sendable {
                self._now = { Instant(box: Instant.Box(clock.now)) }
                self._minimumResolution = { clock.minimumResolution }
                self._sleep = { deadline, tolerance, isolation in
                    guard let box = deadline.box as? Instant.Box<C.Instant> else {
                        preconditionFailure("Mismatched clock instant types")
                    }
                    try await clock.sleep(until: box.instant, tolerance: tolerance, isolation: isolation)
                }
            }

            nonisolated(nonsending)
        }
    }

extension Clock.`Any` {
        public struct Instant: InstantProtocol, Sendable {
            fileprivate let box: any Clock.InstantBox<D>
        }

        public var now: Instant { _now() }

        public var minimumResolution: D { _minimumResolution() }

            public func sleep(until deadline: Instant, tolerance: D? = nil) async throws
        {
            try await sleep(until: deadline, tolerance: tolerance, isolation: #isolation)
        }

        public func sleep(
            until deadline: Instant,
            tolerance: D?,
            isolation: isolated (any Actor)?
        ) async throws {
            try await _sleep(deadline, tolerance, isolation)
        }
}

    extension Clock.`Any`.Instant {
        public func advanced(by duration: D) -> Self {
            Self(box: box.advanced(by: duration))
        }

        public func duration(to other: Self) -> D {
            box.duration(to: other.box)
        }

        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.box.isLess(than: rhs.box)
        }

        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.box.isEqual(to: rhs.box)
        }

        public func hash(into hasher: inout Hasher) {
            box.hash(into: &hasher)
        }
    }

    extension Clock {
        fileprivate protocol InstantBox<D>: Sendable {
            associatedtype D: DurationProtocol & Hashable
            func advanced(by duration: D) -> any Clock.InstantBox<D>
            func duration(to other: any Clock.InstantBox<D>) -> D
            func isLess(than other: any Clock.InstantBox<D>) -> Bool
            func isEqual(to other: any Clock.InstantBox<D>) -> Bool
            func hash(into hasher: inout Hasher)
        }
    }

    extension Clock.`Any`.Instant {
        fileprivate struct Box<I: InstantProtocol>: Clock.InstantBox where I.Duration == D {
            let instant: I

            init(_ instant: I) { self.instant = instant }

            func advanced(by duration: D) -> any Clock.InstantBox<D> {
                Self(instant.advanced(by: duration))
            }

            func duration(to other: any Clock.InstantBox<D>) -> D {
                instant.duration(to: unbox(other))
            }

            func isLess(than other: any Clock.InstantBox<D>) -> Bool {
                instant < unbox(other)
            }

            func isEqual(to other: any Clock.InstantBox<D>) -> Bool {
                instant == unbox(other)
            }

            func hash(into hasher: inout Hasher) {
                hasher.combine(instant)
            }
        }
    }

extension Clock.`Any`.Instant.Box {
        private func unbox(_ other: any Clock.InstantBox<D>) -> I {
            guard let other = other as? Self else {
                preconditionFailure("Mismatched clock instant types")
            }
            return other.instant
        }
}
#endif

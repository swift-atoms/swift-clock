# Clock domain

Clock supplies platform-independent domain identities and deadlines. Time owns
temporal point arithmetic; Tagged preserves domain identity.

## Instants are aliases

```swift
import Clock

// Exact type identity, not a wrapper containing a tagged value:
let instant: Clock.Continuous.Instant = Tagged<Clock.Continuous, Time.Coordinate>(
    _unchecked: Time.Coordinate(offset: .seconds(3))
)
let earlier = instant - .seconds(1)
let elapsed: Swift.Duration = instant - earlier
```

The generic alias is:

```swift
extension Clock {
    public typealias Instant<Domain: ~Copyable & ~Escapable> =
        Tagged<Domain, Time.Coordinate>
}
```

Continuous and suspending instants use different tags. Neither implicitly
converts to the other, to an untagged coordinate, or to a Unix-epoch instant.
Explicitly accessing `underlying` or retagging is a deliberate escape from that
domain distinction; callers must establish the corresponding reference.

Time.Coordinate represents a temporal point relative to an unspecified reference.
It stores a Swift.Duration displacement from that reference, but is not itself
a duration: point plus duration produces a point, and point minus point produces
a duration. Point addition and scaling are not defined.

The coordinate preserves the full signed attosecond range of Swift.Duration.
Native protocol operations trap on unrepresentable arithmetic; checked methods
on Time.Coordinate report overflow. Subtraction uses direct subtraction rather
than negating the duration, including at its minimum value.

The Unix-epoch Instant in swift-time uses the same coordinate implementation
internally, while preserving its Int64 seconds, exact nanosecond precision,
normalized fraction, and existing encoded keys. Those Unix-specific constraints
do not leak into clock instants.

Clock re-exports Time and Tagged so that importing Clock makes its aliased
instants' operations available, including under MemberImportVisibility.

## References and platform boundary

`Clock.Continuous.Instant.reference` is a coordinate origin, not a clock reading.
It does not inherently mean boot time or the Unix epoch. A provider must establish
a consistent reference. Sharing a domain type alone does not make readings from
different machines, boots, or independently chosen references comparable.

The atom provides no `now`, `sleep`, `minimumResolution`, platform source, or
Swift.Clock conformance. Higher packages supply those behaviors and are
responsible for reference consistency, resolution, syscall conversions, sleep,
and cancellation. Representing attoseconds does not claim attosecond hardware
resolution.

There is no Clock.Offset or Clock.Nanoseconds, and no alias to a native platform
clock. Duration is Swift.Duration throughout.

## Deadlines

Clock.Deadline accepts any Swift.InstantProtocol and distinguishes `.at(instant)`
from `.never`. Each built-in domain exposes its corresponding Deadline alias.

```swift
let start = Clock.Continuous.Instant.reference
let deadline = Clock.Continuous.Deadline.after(.seconds(2), from: start)
let remaining: Swift.Duration? = deadline.remaining(at: start)
let unlimited = Clock.Continuous.Deadline.never
```

Finite deadlines expire at equality, with remaining duration clamped to zero.
Never has no finite instant or remaining duration: both projections return nil.
It sorts after every finite deadline, including the largest finite coordinate.
Overflow does not silently become never; negative delays produce past deadlines.

## Migration and verification

Clock instants retain `init(offset:)`, `offset`, and `reference`, supplied by
Time's tagged-coordinate conveniences. Their `underlying` value is now a
Time.Coordinate. There is no intermediate tagged `position` property.

Higher-package migration remains separate. Those packages must supply actual
clock behavior and minimum resolution, and handle optional deadline projections.

Run the Clock, Time, and Calendar tests using the Atoms Temporal Review scheme
in atoms.xcworkspace. After building, verify the public type boundary:

```sh
swift Tests/Typechecking/Verify.swift /path/to/DerivedData/Build/Products/Debug
```

The compiler fixtures verify exact alias identity and valid Swift.Clock clients,
and reject mixed domains, Unix instants, untagged coordinates, invalid point
algebra, and runtime access on domain-only clock values.

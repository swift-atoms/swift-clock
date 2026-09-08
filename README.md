# Clock domain

Clock supplies platform-independent timeline identities and deadline representations.
It does not sample time, sleep, or conform its domain markers to Swift.Clock.

## Exact alias identity

```swift
import Clock

let instant = Clock.Continuous.Instant(offset: .seconds(3))
let tagged: Tagged<Clock.Continuous, Time.Instant> = instant
let deadline = Clock.Continuous.Deadline.at(instant)
```

Clock.Instant<Domain> is exactly Tagged<Domain, Time.Instant>.
Time.Instant is an alias of Time.Coordinate, which is
Tagged<Time, Coordinate<1, Swift.Duration>>.
Neither alias conforms to Swift.InstantProtocol. Duration storage does not by itself
make every generic coordinate a temporal instant.

Continuous and suspending tags prevent accidental mixing. The reference is chosen
by the provider, not necessarily boot time or the Unix epoch. A shared domain tag
does not prove that independently selected runtime references agree.

There is no Clock.Offset, Clock.Nanoseconds, or alias to a platform clock.

## Deadlines

Clock.Deadline<Instant> represents .at(Instant) or .never with no payload protocol
requirements. Equality, hashing, and sendability are conditional. Comparable
payloads support ordering and expiration; never sorts after every finite deadline.
Only after(_:from:) and remaining(at:) require Swift.InstantProtocol.

## Swift interoperability

The swift-time-affine molecule supplies explicit affine arithmetic over Time.Instant.
The existing Point_Affine tagged-composition helper lifts that relationship to a
clock domain. No additional instant wrapper is required for this domain model.

Swift.Clock compatibility and any owned protocol adapter are deferred to the
higher-level provider boundary. Neither importing the atom nor the molecule adds
Swift.InstantProtocol conformance to the aliases or their generic representation.

The owned Unix Instant in swift-time retains its intrinsic arithmetic, Unix epoch,
nanosecond precision, and Swift.InstantProtocol conformance.

## Verification

Use Atoms Coordinate Review in atoms.xcworkspace for the atoms and their explicit
composition molecules. Compiler-negative fixtures in Tests/Typechecking run from
the ordinary Clock test target on macOS: they test programs that must not compile,
which cannot be included directly in a compiling test target.

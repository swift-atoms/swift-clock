# Clock

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Clock types for Swift: phantom-tagged instants, saturating deadlines, and a
family of continuous, suspending, test, immediate, and unimplemented clocks.

## Quick Start

Instants retain their clock identity in the type, so values from different
clocks cannot be mixed accidentally.

```swift
import Clock

let start = Clock.Continuous.Instant(nanoseconds: 1_000_000_000)
let later = start.advanced(by: .seconds(2))

let elapsed: Duration = start.duration(to: later)
let deadline = Clock.Continuous.Deadline.after(.milliseconds(100), from: start)

deadline.hasExpired(at: later)
```

For deterministic tests, `Clock.Test` advances only when directed:

```swift
let clock = Clock.Test()
clock.advance(by: .seconds(5))
clock.now.offset
```

The package also provides `Clock.Suspending`, `Clock.Immediate`,
`Clock.Unimplemented`, and `Clock.Any<Duration>`.

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-atoms/swift-clock.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Clock", package: "swift-clock"),
    ]
)
```

The package uses Swift tools 6.4 and declares Apple platform version 27.

## Products

| Product | Purpose |
|---------|---------|
| `Clock` | Foundation-free clock values, tagged instants, deadlines, and scheduling implementations. |
| `Clock Standard Library Integration` | Standard-library integration surface. |
| `Clock Apple Foundation Integration` | Apple Foundation integration and the package's only Foundation dependency. |

The core product depends only on the canonical
[`swift-tagged`](https://github.com/swift-atoms/swift-tagged) atom.

## Embedded Swift

The core keeps its non-async time surface available under Embedded Swift.
`Clock.Any`, `Clock.Test`, `Clock.Immediate`, and `Clock.Unimplemented` are
excluded with `hasFeature(Embedded)` because their implementations require
concurrency. Foundation remains isolated to the Apple Foundation integration
target.

## Community

<!-- BEGIN: discussion -->
<!-- Discussion thread created at publication. -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).

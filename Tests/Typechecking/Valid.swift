import Clock
import Tagged
import Time

struct LocalDomain: ~Copyable {}

func requireInstant<I: Swift.InstantProtocol>(_ instant: I) -> I { instant }
func requireSendable<Value: Sendable>(_ value: Value) -> Value { value }

let first = requireInstant(Clock.Continuous.Instant.reference)
let later = first + Swift.Duration.seconds(2)
let displacement: Swift.Duration = later - first
let tagged: Tagged<Clock.Continuous, Time.Coordinate> = later
let sameInstant: Clock.Continuous.Instant = tagged
let coordinate: Time.Coordinate = later.underlying
let deadline: Clock.Deadline<Clock.Continuous.Instant> = .at(later)
let never: Clock.Suspending.Deadline = .never
let local = requireSendable(Clock.Instant<LocalDomain>.reference)
let localCopy = local

struct SuppliedClock: Swift.Clock {
    typealias Instant = Clock.Continuous.Instant
    var now: Instant
    var minimumResolution: Swift.Duration { .nanoseconds(100) }
    func sleep(until deadline: Instant, tolerance: Swift.Duration?) async throws {}
}

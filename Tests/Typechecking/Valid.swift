import Clock
import Tagged
import Time
import Point
import Coordinate
import Displacement
import Vector

struct LocalDomain: ~Copyable {}
func requireSendable<Value: Sendable>(_ value: Value) -> Value { value }
let first = Clock.Continuous.Instant.reference
let later = Clock.Continuous.Instant(offset: .seconds(2))
let tagged: Tagged<Clock.Continuous, Time.Instant> = later
let sameInstant: Clock.Continuous.Instant = tagged
let coordinate: Time.Coordinate = later.underlying
let deadline: Clock.Deadline<Clock.Continuous.Instant> = .at(later)
let expired = deadline.hasExpired(at: first)
let never: Clock.Suspending.Deadline = .never
let local = requireSendable(Clock.Instant<LocalDomain>.reference)
let localCopy = local
final class Payload { var state = 0 }
let unconstrained = Clock.Deadline(Payload())

enum Screen {}
let screen = Tagged<Screen, Point<2, Int>>(_unchecked: Point(coordinates: Vector([1, 2])))
let shift = Displacement(components: Vector<2, Int>([3, 4]))
let temporal: Tagged<Time, Coordinate::Coordinate<1, Swift.Duration>> = Time.Coordinate.reference
let one = Point(coordinates: Vector<1, Int>([1]))
let three = Coordinate(components: Vector<3, Int>([1, 2, 3]))
let many = Point(coordinates: Vector<8, Int>(repeating: 0))

let timeInstant: Time.Instant = coordinate
let backToCoordinate: Time.Coordinate = timeInstant

// expected-error: type 'Point<3, Int>' has no member 'origin'
import Point
import Vector
let invalid = Point<3, Int>.origin

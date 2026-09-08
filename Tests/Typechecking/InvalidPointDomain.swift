// expected-error: cannot assign value of type
import Point
import Vector
import Tagged
enum Screen {}
enum World {}
let p = Tagged<World, Point<2, Int>>(_unchecked: Point(coordinates: Vector([1, 2])))
let invalid: Tagged<Screen, Point<2, Int>> = p

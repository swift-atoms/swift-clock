// expected-error: cannot assign value of type 'Tagged<World, Point<2, Int>>' to type 'Tagged<Screen, Point<2, Int>>'
import Point
import Tagged
import Vector

enum Screen {}
enum World {}
let p = Tagged<World, Point<2, Int>>(_unchecked: Point(coordinates: Vector([1, 2])))
let invalid: Tagged<Screen, Point<2, Int>> = p

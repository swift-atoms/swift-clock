// expected-error: binary operator '+' cannot be applied to two 'Point<2, Int>' operands
import Point
import Vector
let p = Point(coordinates: Vector<2, Int>([1, 2]))
let invalid = p + p

// expected-error: binary operator '*' cannot be applied to operands of type 'Point<2, Int>' and 'Int'
import Point
import Vector
let p = Point(coordinates: Vector<2, Int>([1, 2]))
let invalid = p * 2

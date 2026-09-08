// expected-error: cannot assign value of type
import Coordinate
import Vector
let invalid: Coordinate<3, Int> = Coordinate<2, Int>(components: Vector([1, 2]))

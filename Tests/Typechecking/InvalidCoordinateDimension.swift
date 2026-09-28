// expected-error: cannot assign value of type 'Coordinate<2, Int>' to type 'Coordinate<3, Int>'
import Coordinate
import Vector
let invalid: Coordinate<3, Int> = Coordinate<2, Int>(components: Vector([1, 2]))

// expected-error: expected '3' elements in inline array literal, but got '2'
import Point
let invalid = Point<3, Int>([1, 2])

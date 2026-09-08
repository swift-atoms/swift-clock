// expected-error: conform to 'Comparable'
import Point
import Vector
func ordered<T: Comparable>(_ value: T) {}
func invalid() { ordered(Point(coordinates: Vector<2, Int>([1, 2]))) }

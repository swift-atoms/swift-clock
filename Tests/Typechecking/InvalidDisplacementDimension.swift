// expected-error: cannot assign value of type 'Displacement<3, Int>' to type 'Displacement<2, Int>'
import Vector
import Displacement
let d = Displacement(components: Vector<3, Int>([1, 2, 3]))
let invalid: Displacement<2, Int> = d

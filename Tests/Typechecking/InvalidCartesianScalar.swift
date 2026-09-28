// expected-error: static property 'cartesian' requires that 'String' conform to 'AdditiveArithmetic'
import Point
let invalid = Point<2, String>.cartesian

import Point

// No separate Vector import: storage interoperability is part of the public surface.
let storage = Vector(x: 1, y: 2, z: 3)
let value = Point(coordinates: storage)
let natural: Point<3, Int> = .init(x: 1, y: 2, z: 3)
let sameStorage: Vector<3, Int> = natural.coordinates

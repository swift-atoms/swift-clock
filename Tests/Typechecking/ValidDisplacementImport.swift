import Displacement

let storage = Vector(x: 1, y: 2, z: 3)
let value = Displacement(components: storage)
let natural: Displacement<3, Int> = .init(dx: 1, dy: 2, dz: 3)
let sameStorage: Vector<3, Int> = natural.components

enum ElementType: String, CaseIterable {
    // Ground elements
    case flower, moss, grass, vine, puddle, fallenLeaf, mushroom
    // TODO: Implement in polish phase — currently unused in MoodAtmosphere pools
    case pebble
    // Aerial elements
    case butterfly, raindrop, fog, wind, sunray, rainbow
    // Water elements
    case ripple
    // TODO: Implement in polish phase — currently unused in MoodAtmosphere pools
    case reflection
    // Ambient — TODO: Implement in polish phase — currently unused in MoodAtmosphere pools
    case warmLight, breeze, dimLight, shimmer

    var isGround: Bool {
        switch self {
        case .flower, .moss, .grass, .vine, .puddle, .fallenLeaf, .mushroom, .pebble:
            return true
        default:
            return false
        }
    }

    var isAerial: Bool {
        switch self {
        case .butterfly, .raindrop, .fog, .wind, .sunray, .rainbow:
            return true
        default:
            return false
        }
    }
}

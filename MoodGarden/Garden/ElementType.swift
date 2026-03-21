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

    /// Asset catalog image name for image-based elements. Returns nil for programmatic-only elements.
    var imageName: String? {
        switch self {
        case .moss: return "elem_moss"
        case .flower: return "elem_flower"
        case .grass: return "elem_grass"
        case .fog: return "elem_fog"
        case .raindrop: return "elem_raindrop"
        case .wind: return "elem_wind"
        case .fallenLeaf: return "elem_fallenLeaf"
        default: return nil
        }
    }
}

import Foundation

struct ElementSpec: Equatable {
    let entryID: UUID
    let elementType: ElementType
    let seed: Int
    let phase: GrowthPhase
    let zone: PlacementZone
    let estimatedNodes: Int
}

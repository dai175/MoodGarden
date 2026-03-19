enum Season: CaseIterable {
    case spring, summer, autumn, winter

    static func from(month: Int) -> Season {
        switch month {
        case 3, 4, 5:
            return .spring
        case 6, 7, 8:
            return .summer
        case 9, 10, 11:
            return .autumn
        default:
            return .winter
        }
    }
}

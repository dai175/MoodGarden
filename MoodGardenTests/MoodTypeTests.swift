//
//  MoodTypeTests.swift
//  MoodGardenTests
//
//  Created by Daisuke Ooba on 2026/03/17.
//

import Foundation
import Testing

@testable import MoodGarden

struct MoodTypeTests {

    @Test func allSevenCasesExist() {
        let cases = MoodType.allCases
        #expect(cases.count == 7)
    }

    @Test func containsAllExpectedCases() {
        #expect(MoodType.allCases.contains(.peaceful))
        #expect(MoodType.allCases.contains(.happy))
        #expect(MoodType.allCases.contains(.energetic))
        #expect(MoodType.allCases.contains(.anxious))
        #expect(MoodType.allCases.contains(.sad))
        #expect(MoodType.allCases.contains(.angry))
        #expect(MoodType.allCases.contains(.tired))
    }

    @Test func displayNameIsNonEmptyForAllCases() {
        for mood in MoodType.allCases {
            #expect(!mood.displayName.isEmpty, "displayName should not be empty for \(mood)")
        }
    }

    @Test func iconNameIsNonEmptyForAllCases() {
        for mood in MoodType.allCases {
            #expect(!mood.iconName.isEmpty, "iconName should not be empty for \(mood)")
        }
    }

    @Test func eachMoodHasUniqueDisplayName() {
        let names = MoodType.allCases.map(\.displayName)
        let unique = Set(names)
        #expect(unique.count == MoodType.allCases.count)
    }

    @Test func eachMoodHasUniqueIconName() {
        let icons = MoodType.allCases.map(\.iconName)
        let unique = Set(icons)
        #expect(unique.count == MoodType.allCases.count)
    }

    @Test func rawValueMatchesCaseName() {
        #expect(MoodType.peaceful.rawValue == "peaceful")
        #expect(MoodType.happy.rawValue == "happy")
        #expect(MoodType.energetic.rawValue == "energetic")
        #expect(MoodType.anxious.rawValue == "anxious")
        #expect(MoodType.sad.rawValue == "sad")
        #expect(MoodType.angry.rawValue == "angry")
        #expect(MoodType.tired.rawValue == "tired")
    }

    @Test func codableRoundTrip() throws {
        for mood in MoodType.allCases {
            let data = try JSONEncoder().encode(mood)
            let decoded = try JSONDecoder().decode(MoodType.self, from: data)
            #expect(decoded == mood, "Codable round-trip failed for \(mood)")
        }
    }
}

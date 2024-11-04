import SwiftUI
import UnitTestingPreviews

extension TestCase {
    @MainActor
    public var body: some View {
        List {
            Self.tests
        }
    }
}

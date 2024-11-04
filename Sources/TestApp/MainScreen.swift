import CRDT
import SwiftUI

struct MainScreen: View {
    enum Destination: String, CaseIterable {
        case register = "LWW Register Tests"
        
        @MainActor
        var view: any View {
            switch self {
            case .register: LWWRegisterTests()
            }
        }
    }
    @State private var destination: Destination?
    
    var body: some View {
        NavigationSplitView {
            List(Destination.allCases, id: \.self, selection: $destination) {
                Text($0.rawValue)
            }        
        } detail: {
            if let destination {
                AnyView(destination.view)
                    .navigationTitle(destination.rawValue)
            } else {
                Text("Select a test case")
            }
        }
    }
}

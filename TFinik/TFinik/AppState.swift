import Foundation
import Combine

class AppState: ObservableObject {
    @Published var selectedTab: Int = 0
}

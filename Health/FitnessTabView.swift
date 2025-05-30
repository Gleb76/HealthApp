
import SwiftUI

struct FitnessTabView: View {
    
    @State var selectedTabIndex = "Home"
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.stackedLayoutAppearance.selected.iconColor = .green
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.green]
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTabIndex) {
            HomeView()
                .tag("Home")
                .tabItem {
                    Image(systemName: "house")
                }
            HistoricDataView()
                .tag("Historic Data")
                .tabItem {
                    Image(systemName: "chart.bar")
                }
        }
    }
}

#Preview {
    FitnessTabView()
}

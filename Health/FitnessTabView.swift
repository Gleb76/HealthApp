
import SwiftUI

struct FitnessTabView: View {
    
    @State var selectedTabIndex = "Home"
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.stackedLayoutAppearance.selected.iconColor = .green
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.green]

        appearance.stackedLayoutAppearance.normal.iconColor = .gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().standardAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTabIndex) {
            HomeView()
                .tag("Home")
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            HistoricDataView()
                .tag("Historic Data")
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Charts")
                }
        }
    }
}

#Preview {
    FitnessTabView()
}

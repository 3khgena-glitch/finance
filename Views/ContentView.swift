import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Головна", systemImage: "house") }
            
            HistoryView()
                .tabItem { Label("Історія", systemImage: "list.bullet") }
            
            ExportView()
                .tabItem { Label("Експорт", systemImage: "square.and.arrow.up") }
        }
    }
}

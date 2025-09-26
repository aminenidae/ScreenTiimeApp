import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator

    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "star.fill")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("Screen Time Rewards")
                    .font(.title)
                    .padding()

                Text("Project setup complete!")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Home")
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppCoordinator())
    }
}
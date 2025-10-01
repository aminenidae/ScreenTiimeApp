import SwiftUI

@main
struct ScreenTimeRewardsApp: App {
    @StateObject private var appCoordinator = AppCoordinator()
    @StateObject private var deepLinkHandler = DeepLinkHandler()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appCoordinator)
                .environmentObject(deepLinkHandler)
                .onOpenURL { url in
                    deepLinkHandler.handleURL(url)
                }
                .sheet(isPresented: $deepLinkHandler.showInvitationSheet) {
                    if let invitation = deepLinkHandler.pendingInvitation {
                        InvitationAcceptanceView(
                            invitation: invitation,
                            deepLinkHandler: deepLinkHandler
                        )
                    }
                }
        }
    }
}
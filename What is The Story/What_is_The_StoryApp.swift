//
//  What_is_The_StoryApp.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-01-10.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFunctions


class AppDelegate: NSObject, UIApplicationDelegate {
    static var db: Firestore!
    static var storage: Storage!
    let navigationManager = NavigationManager()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        AppDelegate.db = Firestore.firestore()
        AppDelegate.storage = Storage.storage()
        
#if EMULATORS
        print("******* EMULATOR *******")
        Auth.auth().useEmulator(withHost:"localhost", port:9099)
        Storage.storage().useEmulator(withHost: "localhost", port: 9199)
        let settings = Firestore.firestore().settings
        settings.host = "localhost:8080"
        settings.isPersistenceEnabled = true
        settings.isSSLEnabled = false
        AppDelegate.db.settings = settings
        Storage.storage().useEmulator(withHost: "localhost", port: 9199)
        Functions.functions().useEmulator(withHost:"localhost", port:5001)

#elseif DEBUG
        print("****** DEBIGGER *******")
#endif
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let incomingURL = userActivity.webpageURL {
            // Parse the incoming URL
            let urlComponents = URLComponents(url: incomingURL, resolvingAgainstBaseURL: true)
            let episodeID = urlComponents?.queryItems?.first(where: { $0.name == "ep" })?.value
            let invterCode = urlComponents?.queryItems?.first(where:{ $0.name == "inviter" })?.value

            // Set the episode ID in the Navigation Manager
            DispatchQueue.main.async {
                if let episodeID = episodeID {
                    self.navigationManager.selectedEpisodeID = episodeID
                    self.navigationManager.invitationCode = invterCode
                } else {
                    self.navigationManager.selectedEpisodeID = nil // Default to home page
                }
            }

            return true
        }
        return false
    }
}

@main
struct What_is_The_StoryApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    // @StateObject var pathRouter = PathRouter()
    @StateObject var playerVM = PlayerVM()
    @StateObject var userVM = UserVM()
    @StateObject var themeManager = ThemeManager()
    @StateObject var errorHandling = ErrorHandlingVM(errorReporter: CrashlyticsManager())
    @Environment(\.colorScheme) var colorScheme
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appDelegate.navigationManager)
                .environmentObject(playerVM)
                .environmentObject(userVM)
                .environmentObject(errorHandling)
                .environmentObject(themeManager.current)
                .onAppear {
                    themeManager.updateTheme(for: colorScheme)
                }
                .onChange(of: colorScheme) { newScheme in
                    themeManager.updateTheme(for: newScheme)
                }
        }
    }
}

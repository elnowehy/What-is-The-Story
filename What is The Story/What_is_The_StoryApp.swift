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


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
#if EMULATORS
        print("******* EMULATOR *******")
        Auth.auth().useEmulator(withHost:"localhost", port:9099)
        Storage.storage().useEmulator(withHost: "localhost", port: 9199)
        let settings = Firestore.firestore().settings
        settings.host = "localhost:8080"
        settings.isPersistenceEnabled = true
        settings.isSSLEnabled = false
        Firestore.firestore().settings = settings
#elseif DEBUG
        print("****** DEBIGGER *******")
#endif
        return true
    }
}

@main
struct What_is_The_StoryApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var pathRouter = PathRouter()
    @StateObject var authManager = AuthManager()
    @StateObject var userVM = UserVM()
    @StateObject var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(pathRouter)
                .environmentObject(userVM)
                .environmentObject(themeManager.current)
        }
    }
}

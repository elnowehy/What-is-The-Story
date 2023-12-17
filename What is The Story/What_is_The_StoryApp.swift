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
}

@main
struct What_is_The_StoryApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var pathRouter = PathRouter()
    @StateObject var userVM = UserVM()
    @StateObject var themeManager = ThemeManager()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(pathRouter)
                .environmentObject(userVM)
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

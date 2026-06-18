import SwiftUI
import FirebaseCore
import FirebaseDatabase

@main
struct CookTogetherApp: App {
    
    init() {
        FirebaseApp.configure()
        // Test kodunu sil
    }
    
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}

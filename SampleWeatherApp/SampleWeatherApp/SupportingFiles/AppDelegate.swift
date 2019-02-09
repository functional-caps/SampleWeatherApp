import SampleWeatherFramework
import UIKit

final class AppDelegate: UIResponder, UIApplicationDelegate {

    private let window: UIWindow = UIWindow(frame: UIScreen.main.bounds)

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        window.rootViewController = ViewController()
        window.makeKeyAndVisible()
        
        return true
    }
}

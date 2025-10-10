import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    var resolvedKey: String?

    if let plistKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !plistKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      resolvedKey = plistKey
    } else {
      let environment = ProcessInfo.processInfo.environment
      if let iosKey = environment["GOOGLE_MAPS_IOS_KEY"], !iosKey.isEmpty {
        resolvedKey = iosKey
      } else if let sharedKey = environment["GOOGLE_MAPS_API_KEY"], !sharedKey.isEmpty {
        resolvedKey = sharedKey
      }
    }

    if let apiKey = resolvedKey {
      GMSServices.provideAPIKey(apiKey)
    } else {
      NSLog("[AppDelegate] Google Maps API key not provided")
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

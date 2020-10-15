# VersionCheck

A library for doing checking of supported versions for a network service

Example usage:

```
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var upgradeDisplay: DefaultUpgradeDisplay?
    var versionCheck: VersionCheck?
    
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        upgradeDisplay = DefaultUpgradeDisplay(isTestBuild: false)
        versionCheck = VersionCheck(url: "https://myservice.com/api/version",
                         displayHandler: upgradeDisplay.displayStateChanged)
    }
}
```

Expected JSON format:

```
{
  "ios" : {
    "minimumVersion": "1.1",
    "blockedVersions": ["1.2.0", "1.2.1", "@301"],
    "latestTestVersion": "1.4.2@400"
  },
  "android" : {
    "minimumVersion": "1.1",
    "blockedVersions": ["1.2.0", "1.2.1", "@301"],
    "latestTestVersion": "1.4.2@400"
  },
  "serverForceVersionFailure": false,
  "serverMaintenance": false
}

```

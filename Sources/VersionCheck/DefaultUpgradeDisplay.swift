//
//  DefaultUpgradeDisplay.swift
//  
//

#if canImport(UIKit)
import Foundation
import UIKit

public class DefaultUpgradeDisplay {
    private var lastState: DisplayState = .clear
    private var alert: UIAlertController?
    private var isTestBuild: Bool

    public init(isTestBuild: Bool = false) {
        self.isTestBuild = isTestBuild
    }

    public func displayStateChanged(_ state: DisplayState) {
        if state == lastState {
            return
        }

        lastState = state

        if alert != nil {
            alert?.dismiss(animated: true, completion: nil)
            alert = nil
        }

        switch state {
        case .clear:
            break
        case .forceUpdate:
            showAlert(title: "Must Update", message: "The version of the application is out of date and cannot run. Please update to the latest version from the App Store", allowContinue: false)
        case .suggestUpdate:
            if isTestBuild {
                showAlert(title: "Should Update", message: "This test version of the application is out of date and may not work as expected. Please update to the latest version via the TestFlight, Ad Hoc build distribution or the App Store.", allowContinue: true)
            }
        case .downForMaintenance:
            showAlert(title: "Down for Maintenance", message: "The server is currently down for maintenance. Please check back later.", allowContinue: false)
        case .developmentFailure(let message):
            showAlert(title:"Version Check Error", message: message, allowContinue: true)
        }
    }

    private func showAlert(title: String, message: String, allowContinue: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        self.alert = alert

        if allowContinue {
            alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { _ in
                self.alert?.dismiss(animated: true, completion: nil)
                self.alert = nil
            }))
        }

        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
#endif

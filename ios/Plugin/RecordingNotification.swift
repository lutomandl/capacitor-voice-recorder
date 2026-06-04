import Foundation
import UIKit
import UserNotifications

/// Surfaces a "recording in progress" notification in Notification Center while a chunked
/// recording runs and the app is in the OS background — the iOS counterpart to the Android
/// foreground-service notification.
///
/// iOS suppresses notifications delivered while the app is in the foreground unless the app
/// owns the UNUserNotificationCenter presentation delegate (Capacitor's push plugin already
/// does, and fighting it risks breaking push). So we post the notification when the app
/// enters the background — exactly when the indicator is useful — and clear it when the app
/// returns to the foreground or recording stops.
class RecordingNotification {

    private static let identifier = "voice_recording_active"

    private var didEnterBackgroundObserver: NSObjectProtocol?
    private var willEnterForegroundObserver: NSObjectProtocol?

    func start() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }

        didEnterBackgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            RecordingNotification.post()
        }
        willEnterForegroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            RecordingNotification.clear()
        }
    }

    func stop() {
        if let observer = didEnterBackgroundObserver {
            NotificationCenter.default.removeObserver(observer)
            didEnterBackgroundObserver = nil
        }
        if let observer = willEnterForegroundObserver {
            NotificationCenter.default.removeObserver(observer)
            willEnterForegroundObserver = nil
        }
        RecordingNotification.clear()
    }

    private static func post() {
        let content = UNMutableNotificationContent()
        content.title = "Recording"
        content.body = "Meeting recording in progress"
        // No sound — this is a passive ongoing-recording indicator.
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    private static func clear() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.removeDeliveredNotifications(withIdentifiers: [identifier])
    }
}

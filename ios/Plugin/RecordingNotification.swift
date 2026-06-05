import Foundation
import UIKit
import UserNotifications

/// Surfaces a "recording in progress" notification in Notification Center while a chunked
/// recording runs — the iOS counterpart to the Android foreground-service notification.
/// Posted when recording starts and re-posted when the app enters the background; cleared on stop.
class RecordingNotification {

    private static let identifier = "voice_recording_active"

    private var observers: [NSObjectProtocol] = []
    private var isActive = false

    func start() {
        isActive = true

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }

        let observer = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard self?.isActive == true else { return }
            RecordingNotification.post()
        }
        observers.append(observer)

        RecordingNotification.post()
    }

    func stop() {
        isActive = false
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        observers.removeAll()
        RecordingNotification.clear()
    }

    private static func post() {
        let content = UNMutableNotificationContent()
        content.title = "Recording"
        content.body = "Meeting recording in progress"
        // A short scheduled trigger (rather than a nil "immediate" trigger) reliably lands the
        // notification in Notification Center in this FCM-integrated app.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private static func clear() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.removeDeliveredNotifications(withIdentifiers: [identifier])
    }
}

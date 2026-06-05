import Foundation
import UIKit
import UserNotifications

/// Surfaces a "recording in progress" notification in Notification Center while a chunked
/// recording runs — the iOS counterpart to the Android foreground-service notification.
///
/// We post it as soon as recording starts (the host app's notification delegate presents
/// foreground notifications) and re-post whenever the app enters the background (where iOS
/// delivers it straight into Notification Center). It stays until recording stops.
class RecordingNotification {

    private static let identifier = "voice_recording_active"

    private var observers: [NSObjectProtocol] = []
    private var isActive = false

    func start() {
        isActive = true

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            NSLog("[VoiceRecorder] RecordingNotification auth granted=\(granted) error=\(String(describing: error))")
            RecordingNotification.post()
        }

        let center = NotificationCenter.default
        for name in [UIApplication.didEnterBackgroundNotification, UIApplication.willResignActiveNotification] {
            observers.append(
                center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                    guard self?.isActive == true else { return }
                    NSLog("[VoiceRecorder] RecordingNotification re-post on \(name.rawValue)")
                    RecordingNotification.post()
                }
            )
        }

        // Post immediately too — recording starts in the foreground, which the host app's
        // UNUserNotificationCenter delegate presents.
        RecordingNotification.post()
    }

    func stop() {
        isActive = false
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        observers.removeAll()
        RecordingNotification.clear()
    }

    private static func post() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            NSLog("[VoiceRecorder] RecordingNotification post; authStatus=\(settings.authorizationStatus.rawValue)")
            let content = UNMutableNotificationContent()
            content.title = "Recording"
            content.body = "Meeting recording in progress"
            // No sound — passive ongoing-recording indicator.
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
            center.add(request) { error in
                if let error = error {
                    NSLog("[VoiceRecorder] RecordingNotification add error: \(error)")
                }
            }
        }
    }

    private static func clear() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.removeDeliveredNotifications(withIdentifiers: [identifier])
    }
}

//
//  AppSync.swift
//  WatchYourLanguageAAC
//

import Foundation
import WatchConnectivity

/// Keys identifying each synced data set within the application context.
enum SyncKey {
    static let phrases = "phrases"
    static let favourites = "favourites"
    static let customWords = "customWords"
    static let settings = "settings"
}

/// Thin WatchConnectivity wrapper shared by the app's stores.
///
/// WCSession has a single delegate, so this one object owns the session and
/// fans payloads out to registered stores. Sync uses
/// `updateApplicationContext`, which keeps only the latest payload and
/// delivers it when the counterpart app next runs — the right fit for
/// last-writer-wins state sync. Each store's payload lives under its own key
/// in the context dictionary.
nonisolated final class AppSync: NSObject, WCSessionDelegate {

    @MainActor static let shared = AppSync()

    @MainActor private var channels: [String: Channel] = [:]
    @MainActor private var lastPushed: [String: [String: Any]] = [:]
    @MainActor private var isActivated = false

    private struct Channel {
        let onReceive: ([String: Any]) -> Void
        let onActivated: () -> Void
    }

    /// Registers a store's interest in one context key. `onReceive` is called
    /// on the main actor with the counterpart's payload; `onActivated` fires
    /// once the session is ready, so the store can push its current state.
    @MainActor
    func register(key: String, onReceive: @escaping ([String: Any]) -> Void, onActivated: @escaping () -> Void) {
        channels[key] = Channel(onReceive: onReceive, onActivated: onActivated)
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        if session.delegate == nil {
            session.delegate = self
            session.activate()
        } else if isActivated {
            deliver(session.receivedApplicationContext, only: key)
            onActivated()
        }
    }

    @MainActor
    func push(key: String, payload: [String: Any]) {
        lastPushed[key] = payload
        guard WCSession.isSupported(), WCSession.default.activationState == .activated else { return }
        do {
            try WCSession.default.updateApplicationContext(lastPushed)
        } catch {
            print("Failed to push \(key): \(error)")
        }
    }

    @MainActor
    private func deliver(_ context: [String: Any], only key: String? = nil) {
        for (channelKey, channel) in channels {
            if let key, channelKey != key { continue }
            if let payload = context[channelKey] as? [String: Any] {
                channel.onReceive(payload)
            }
        }
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        guard activationState == .activated else { return }
        // Adopt anything the counterpart sent while we weren't running,
        // then let each store share its own state in case it is newer.
        let received = session.receivedApplicationContext
        Task { @MainActor in
            isActivated = true
            deliver(received)
            for channel in channels.values {
                channel.onActivated()
            }
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in
            deliver(applicationContext)
        }
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        // Re-activate after the user switches to a different paired watch.
        session.activate()
    }
    #endif
}

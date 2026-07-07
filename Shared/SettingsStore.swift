//
//  SettingsStore.swift
//  WatchYourLanguageAAC
//

import Foundation
import Observation

/// Settings that shape the watch experience but can be changed from either
/// device, synced like the other stores. The value is mirrored into
/// UserDefaults so watch views can keep reading it live via `@AppStorage`.
@Observable
final class SettingsStore {
    static let shared = SettingsStore()

    private(set) var showsDisabilityBadge: Bool

    private var lastModified: Date

    private static let modifiedKey = "syncedSettingsModified"

    private init() {
        let defaults = UserDefaults.standard
        showsDisabilityBadge = defaults.object(forKey: SettingsKeys.showsDisabilityBadge) as? Bool ?? true
        lastModified = Date(timeIntervalSince1970: defaults.double(forKey: Self.modifiedKey))
        AppSync.shared.register(key: SyncKey.settings) { [weak self] payload in
            guard let self,
                  let value = payload["showsDisabilityBadge"] as? Bool,
                  let timestamp = payload["modified"] as? TimeInterval else { return }
            applyRemote(showsDisabilityBadge: value, modified: Date(timeIntervalSince1970: timestamp))
        } onActivated: { [weak self] in
            self?.pushCurrent()
        }
    }

    func setShowsDisabilityBadge(_ value: Bool) {
        showsDisabilityBadge = value
        lastModified = .now
        persist()
        pushCurrent()
    }

    private func applyRemote(showsDisabilityBadge value: Bool, modified: Date) {
        guard modified > lastModified else { return }
        showsDisabilityBadge = value
        lastModified = modified
        persist()
    }

    private func pushCurrent() {
        AppSync.shared.push(key: SyncKey.settings, payload: [
            "showsDisabilityBadge": showsDisabilityBadge,
            "modified": lastModified.timeIntervalSince1970,
        ])
    }

    private func persist() {
        let defaults = UserDefaults.standard
        defaults.set(showsDisabilityBadge, forKey: SettingsKeys.showsDisabilityBadge)
        defaults.set(lastModified.timeIntervalSince1970, forKey: Self.modifiedKey)
    }
}

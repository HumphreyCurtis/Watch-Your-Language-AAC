//
//  FavouritesStore.swift
//  WatchYourLanguageAAC
//

import Foundation
import Observation

/// The user's favourite words, kept in sync between iPhone and watch.
///
/// The list lives in a JSON file on each device; every change stamps
/// `lastModified` and pushes the whole list to the counterpart via
/// `AppSync`. Whichever device edited last wins, which is enough for a
/// list this small and avoids per-entry merge bookkeeping.
@Observable
final class FavouritesStore {
    static let shared = FavouritesStore()

    /// Most recent first.
    private(set) var words: [String] = []

    private var lastModified = Date.distantPast

    private static let maximumCount = 100

    private var fileURL: URL {
        URL.documentsDirectory.appending(path: "Favourites.json")
    }

    private struct Snapshot: Codable {
        var words: [String]
        var lastModified: Date
    }

    private init() {
        load()
        AppSync.shared.register(key: SyncKey.favourites) { [weak self] payload in
            guard let self,
                  let remoteWords = payload["words"] as? [String],
                  let timestamp = payload["modified"] as? TimeInterval else { return }
            applyRemote(words: remoteWords, modified: Date(timeIntervalSince1970: timestamp))
        } onActivated: { [weak self] in
            self?.pushCurrent()
        }
    }

    /// Records that a word was used, moving it to the front of the list.
    func noteUsed(_ word: String) {
        let cleaned = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }
        var updated = words.filter { $0.caseInsensitiveCompare(cleaned) != .orderedSame }
        updated.insert(cleaned, at: 0)
        if updated.count > Self.maximumCount {
            updated.removeLast(updated.count - Self.maximumCount)
        }
        setWords(updated)
    }

    func remove(atOffsets offsets: IndexSet) {
        var updated = words
        for index in offsets.sorted(by: >) where updated.indices.contains(index) {
            updated.remove(at: index)
        }
        setWords(updated)
    }

    private func setWords(_ updated: [String]) {
        words = updated
        lastModified = .now
        save()
        pushCurrent()
    }

    private func applyRemote(words remoteWords: [String], modified: Date) {
        guard modified > lastModified else { return }
        words = remoteWords
        lastModified = modified
        save()
    }

    private func pushCurrent() {
        AppSync.shared.push(key: SyncKey.favourites, payload: [
            "words": words,
            "modified": lastModified.timeIntervalSince1970,
        ])
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(Snapshot(words: words, lastModified: lastModified))
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save favourites: \(error)")
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) else { return }
        words = snapshot.words
        lastModified = snapshot.lastModified
    }
}

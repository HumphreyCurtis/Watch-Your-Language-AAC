//
//  PhraseStore.swift
//  WatchYourLanguageAAC
//

import Foundation
import Observation

/// The user's phrase library, kept in sync between iPhone and watch.
///
/// Starts as `PhraseLibrary.defaults` and becomes user-owned once edited.
/// Every change stamps `lastModified` and pushes the whole list to the
/// counterpart device; whichever device edited last wins.
@Observable
final class PhraseStore {
    static let shared = PhraseStore()

    private(set) var phrases: [Phrase] = PhraseLibrary.defaults

    private var lastModified = Date.distantPast

    /// Bump when new example phrases join `PhraseLibrary.defaults`, so
    /// lists saved by earlier versions pick them up once (and only once —
    /// deleting an example afterwards is respected).
    private static let currentSeedVersion = 2

    private var seedVersion = PhraseStore.currentSeedVersion

    private var fileURL: URL {
        URL.documentsDirectory.appending(path: "Phrases.json")
    }

    private struct Snapshot: Codable {
        var phrases: [Phrase]
        var lastModified: Date
        var seedVersion: Int?
    }

    private init() {
        load()
        AppSync.shared.register(key: SyncKey.phrases) { [weak self] payload in
            guard let self,
                  let data = payload["data"] as? Data,
                  let timestamp = payload["modified"] as? TimeInterval,
                  let remotePhrases = try? JSONDecoder().decode([Phrase].self, from: data) else { return }
            applyRemote(phrases: remotePhrases, modified: Date(timeIntervalSince1970: timestamp))
        } onActivated: { [weak self] in
            self?.pushCurrent()
        }
    }

    /// Adds the phrase, or updates the existing phrase with the same id.
    func save(_ phrase: Phrase) {
        var updated = phrases
        if let index = updated.firstIndex(where: { $0.id == phrase.id }) {
            updated[index] = phrase
        } else {
            updated.append(phrase)
        }
        setPhrases(updated)
    }

    func remove(id: UUID) {
        setPhrases(phrases.filter { $0.id != id })
    }

    func remove(atOffsets offsets: IndexSet) {
        var updated = phrases
        for index in offsets.sorted(by: >) where updated.indices.contains(index) {
            updated.remove(at: index)
        }
        setPhrases(updated)
    }

    private func setPhrases(_ updated: [Phrase]) {
        phrases = updated
        lastModified = .now
        saveToDisk()
        pushCurrent()
    }

    private func applyRemote(phrases remotePhrases: [Phrase], modified: Date) {
        guard modified > lastModified else { return }
        phrases = remotePhrases
        lastModified = modified
        saveToDisk()
    }

    private func pushCurrent() {
        guard let data = try? JSONEncoder().encode(phrases) else { return }
        AppSync.shared.push(key: SyncKey.phrases, payload: [
            "data": data,
            "modified": lastModified.timeIntervalSince1970,
        ])
    }

    private func saveToDisk() {
        do {
            let snapshot = Snapshot(phrases: phrases, lastModified: lastModified, seedVersion: seedVersion)
            let data = try JSONEncoder().encode(snapshot)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save phrases: \(error)")
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) else { return }
        phrases = snapshot.phrases
        lastModified = snapshot.lastModified
        seedVersion = snapshot.seedVersion ?? 1
        seedNewDefaultsIfNeeded()
    }

    /// Appends example phrases introduced after this list was first saved.
    private func seedNewDefaultsIfNeeded() {
        guard seedVersion < Self.currentSeedVersion else { return }
        seedVersion = Self.currentSeedVersion
        let existingLabels = Set(phrases.map { $0.label.lowercased() })
        let newExamples = PhraseLibrary.multilingualExamples.filter {
            !existingLabels.contains($0.label.lowercased())
        }
        if newExamples.isEmpty {
            saveToDisk()
        } else {
            setPhrases(phrases + newExamples)
        }
    }
}

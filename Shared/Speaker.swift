//
//  Speaker.swift
//  WatchYourLanguageAAC
//

import AVFoundation
import Foundation

/// App-wide text-to-speech engine.
///
/// A single shared instance so the synthesizer outlives the view that
/// triggered speech — a synthesizer owned by a view struct can be
/// deallocated mid-utterance when the view re-renders.
final class Speaker {
    static let shared = Speaker()

    /// Matches the rate the original research app used.
    static let defaultRate = 0.57

    private let synthesizer = AVSpeechSynthesizer()

    private init() {}

    func speak(_ phrase: Phrase) {
        speak(phrase.spokenText, languageCode: phrase.languageCode)
    }

    func speak(_ text: String, languageCode: String? = nil) {
        let rate = UserDefaults.standard.object(forKey: SettingsKeys.speechRate) as? Double
            ?? Self.defaultRate

        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = Float(rate)
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 0.8
        utterance.voice = voice(for: languageCode)

        // Repeated taps restart the phrase rather than queueing copies.
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }

    /// Picks a voice for the requested language (falling back to the device
    /// language), honouring the user's voice-gender preference.
    ///
    /// The language still has to match — a French phrase read by an English
    /// voice is not understandable — but the region does not. Most devices
    /// ship one voice per exact locale, and on a UK device that is Daniel,
    /// who is male, so insisting on `en-GB` made the Female voice switch do
    /// nothing at all. Any female English voice will do; an American accent
    /// is a much smaller problem than a switch that does not work.
    private func voice(for languageCode: String?) -> AVSpeechSynthesisVoice? {
        let language = languageCode ?? AVSpeechSynthesisVoice.currentLanguageCode()
        let primary = language.prefix { $0 != "-" }
        let prefersFemale = UserDefaults.standard.bool(forKey: SettingsKeys.prefersFemaleVoice)
        let preferredGender: AVSpeechSynthesisVoiceGender = prefersFemale ? .female : .male

        let sameLanguage = AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix(primary) }

        return sameLanguage.first { $0.gender == preferredGender }
            ?? sameLanguage.first { $0.language == language }
            // The system's own default for the language — never one of the
            // novelty voices (Bells, Zarvox) that share the English pool.
            ?? AVSpeechSynthesisVoice(language: language)
    }
}

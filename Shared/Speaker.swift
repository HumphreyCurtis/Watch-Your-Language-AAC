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
    /// The preference is worth crossing a region for. Most devices ship a
    /// single voice per exact locale — a UK device has only Daniel, who is
    /// male — so matching on `en-GB` alone means the toggle silently does
    /// nothing. Widening to the language lets it reach Samantha or Karen.
    /// A different English accent is a smaller surprise than a switch that
    /// visibly does not work.
    private func voice(for languageCode: String?) -> AVSpeechSynthesisVoice? {
        let language = languageCode ?? AVSpeechSynthesisVoice.currentLanguageCode()
        let primary = language.prefix { $0 != "-" }
        let prefersFemale = UserDefaults.standard.bool(forKey: SettingsKeys.prefersFemaleVoice)
        let preferredGender: AVSpeechSynthesisVoiceGender = prefersFemale ? .female : .male

        let all = AVSpeechSynthesisVoice.speechVoices()
        let exact = all.filter { $0.language == language }
        let sameLanguage = all.filter { $0.language.hasPrefix(primary) }

        return exact.first { $0.gender == preferredGender }
            // Right gender, wrong region — still better than ignoring it.
            ?? sameLanguage.first { $0.gender == preferredGender }
            ?? exact.first
            // The novelty voices (Bells, Zarvox, Bad News) report an
            // unspecified gender and are in the language pool. Requiring a
            // declared gender keeps a phrase from being read out in one of
            // them, which in this app would be humiliating rather than fun.
            ?? sameLanguage.first { $0.gender != .unspecified }
            ?? AVSpeechSynthesisVoice(language: language)
    }
}
